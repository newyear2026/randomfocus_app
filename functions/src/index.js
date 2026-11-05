import {onRequest} from 'firebase-functions/v2/https';
import {GoogleAuth} from 'google-auth-library';
import {BillingError, createPlayBilling} from './play_billing.js';

const auth = new GoogleAuth({
  scopes: ['https://www.googleapis.com/auth/androidpublisher'],
});
const billing = createPlayBilling({
  enabled: () => process.env.RANDOMFOCUS_BILLING_ENABLED === 'true',
  request: async options => {
    const client = await auth.getClient();
    return client.request({...options, timeout: 6000});
  },
});

// Purchase tokens are bearer receipts; the app has no user-account system.
// Google Play verifies ownership during checkout/restore and the backend checks
// every presented receipt against Google's API. No local entitlement is trusted.
// Do not log request bodies, tokens, raw Google API errors, or authorization.
export const verifyRandomFocusPro = onRequest({
  region: 'us-central1',
  serviceAccount: 'randomfocus-billing@cs-project-nuszgcho.iam.gserviceaccount.com',
  // Domain-restricted sharing disallows the allUsers IAM binding. Mobile HTTPS
  // access is enabled on this service via Cloud Run invokerIamDisabled instead.
  invoker: 'private',
  minInstances: 0,
  maxInstances: 3,
  concurrency: 20,
  memory: '256MiB',
  timeoutSeconds: 20,
}, async (req, res) => {
  res.set('Cache-Control', 'no-store');
  res.set('X-Content-Type-Options', 'nosniff');
  try {
    if (req.method === 'GET') {
      res.status(200).json(await billing.status());
      return;
    }
    if (req.method !== 'POST') {
      res.set('Allow', 'GET, POST').status(405).json({error: 'method-not-allowed'});
      return;
    }
    if (!req.is('application/json') || req.rawBody?.length > 8192) {
      res.status(400).json({error: 'invalid-request'});
      return;
    }
    res.status(200).json(await billing.verify(req.body));
  } catch (error) {
    // Only explicitly classified, sanitized errors are returned to the client.
    if (error instanceof BillingError) {
      res.status(error.status).json({error: error.code});
    } else {
      res.status(503).json({error: 'verification-unavailable'});
    }
  }
});
