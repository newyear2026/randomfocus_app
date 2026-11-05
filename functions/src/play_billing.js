export const packageName = 'com.randomfocus.app';
export const productId = 'randomfocus_pro_lifetime';
const publisherBase = 'https://androidpublisher.googleapis.com/androidpublisher/v3';

export class BillingError extends Error {
  constructor(status, code) {
    super(code);
    this.status = status;
    this.code = code;
  }
}

// No caller-controlled package/product IDs: other apps in the shared Firebase
// project must never be able to turn their purchases into RandomFocus Pro.
export function createPlayBilling({request, enabled}) {
  const identity = {packageName, productId};
  return {
    async status() {
      if (!enabled()) return {...identity, ready: false};
      // Check the actual catalog/API access before allowing the app to charge.
      try {
        await request({
          method: 'GET',
          url: `${publisherBase}/applications/${packageName}/oneTimeProducts/${productId}`,
        });
      } catch (error) {
        // Configuration failures keep checkout disabled without making a
        // healthy verification endpoint look like a network/server outage.
        const status = error.response?.status;
        if (status === 404 || status === 403) {
          return {
            ...identity,
            ready: false,
            reason: status === 404 ? 'product-not-configured' : 'catalog-access-denied',
          };
        }
        throw error;
      }
      return {...identity, ready: true};
    },
    async verify(body) {
      if (!body || typeof body !== 'object' || Array.isArray(body) ||
          Object.keys(body).some(key => key !== 'purchaseToken') ||
          typeof body.purchaseToken !== 'string' ||
          body.purchaseToken.length < 1 || body.purchaseToken.length > 4096 ||
          body.purchaseToken.trim() !== body.purchaseToken ||
          /[\x00-\x20\x7f]/.test(body.purchaseToken)) {
        throw new BillingError(400, 'invalid-request');
      }
      // Existing buyers can still verify/restore if new sales are disabled.
      const purchaseUrl = `${publisherBase}/applications/${packageName}/purchases/products/${productId}/tokens/${encodeURIComponent(body.purchaseToken)}`;
      let purchase;
      try {
        ({data: purchase} = await request({method: 'GET', url: purchaseUrl}));
      } catch (error) {
        const status = error.response?.status;
        if (status === 400 || status === 404 || status === 410) {
          throw new BillingError(422, 'invalid-purchase');
        }
        throw error;
      }
      if (purchase.purchaseState === 2) return {...identity, state: 'pending'};
      if (purchase.purchaseState === 1) return {...identity, state: 'revoked'};
      if (purchase.purchaseState !== 0 || purchase.consumptionState !== 0 ||
          (purchase.productId && purchase.productId !== productId) ||
          (purchase.quantity !== undefined && purchase.quantity !== 1)) {
        throw new BillingError(422, 'invalid-purchase');
      }
      if (purchase.acknowledgementState !== 1) {
        await request({method: 'POST', url: `${purchaseUrl}:acknowledge`, data: {}});
      }
      // Never consume this purchase: ownership must survive reinstalls.
      return {...identity, state: 'purchased', acknowledged: true};
    },
  };
}
