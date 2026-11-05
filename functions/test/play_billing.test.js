import {test} from 'node:test';
import assert from 'node:assert/strict';
import {BillingError, createPlayBilling, packageName, productId} from '../src/play_billing.js';

const paid = {purchaseState: 0, consumptionState: 0, acknowledgementState: 0};
function setup(purchase = paid, {enabled = true, failAcknowledgment = false} = {}) {
  const calls = [];
  const billing = createPlayBilling({
    enabled: () => enabled,
    request: async call => {
      calls.push(call);
      if (call.method === 'POST' && failAcknowledgment) throw new Error('offline');
      return {data: purchase};
    },
  });
  return {billing, calls};
}

test('paid non-consumable is checked with Google and acknowledged once', async () => {
  const {billing, calls} = setup();
  assert.deepEqual(await billing.verify({purchaseToken: 'token/with+characters'}),
    {packageName, productId, state: 'purchased', acknowledged: true});
  assert.equal(calls.length, 2);
  assert.match(calls[0].url, /com.randomfocus.app\/purchases\/products\/randomfocus_pro_lifetime\/tokens\/token%2Fwith%2Bcharacters$/);
  assert.match(calls[1].url, /:acknowledge$/);
  assert.ok(calls.every(call => !call.url.endsWith(':consume')));
});
test('already acknowledged restore is idempotent', async () => {
  const {billing, calls} = setup({...paid, acknowledgementState: 1});
  assert.equal((await billing.verify({purchaseToken: 'existing'})).state, 'purchased');
  assert.equal(calls.length, 1);
});
for (const [state, result] of [[2, 'pending'], [1, 'revoked']]) {
  test(`${result} purchases are never acknowledged or unlocked`, async () => {
    const {billing, calls} = setup({...paid, purchaseState: state});
    assert.equal((await billing.verify({purchaseToken: 'token'})).state, result);
    assert.equal(calls.length, 1);
  });
}
for (const purchase of [
  {...paid, purchaseState: 99}, {...paid, consumptionState: 1},
  {...paid, productId: 'some-other-product'}, {...paid, quantity: 2}, {},
]) {
  test(`invalid purchase is rejected: ${JSON.stringify(purchase)}`, async () => {
    const {billing, calls} = setup(purchase);
    await assert.rejects(billing.verify({purchaseToken: 'token'}), BillingError);
    assert.equal(calls.length, 1);
  });
}
test('unconfirmed acknowledgment cannot grant an entitlement', async () => {
  const {billing} = setup(paid, {failAcknowledgment: true});
  await assert.rejects(billing.verify({purchaseToken: 'token'}), /offline/);
});
test('disabled new sales still permit existing purchasers to restore', async () => {
  const {billing, calls} = setup(paid, {enabled: false});
  assert.equal((await billing.status()).ready, false);
  assert.equal(calls.length, 0);
  assert.equal((await billing.verify({purchaseToken: 'token'})).state, 'purchased');
});
test('readiness checks catalog access rather than only returning a flag', async () => {
  const {billing, calls} = setup();
  assert.equal((await billing.status()).ready, true);
  assert.match(calls[0].url, /\/oneTimeProducts\/randomfocus_pro_lifetime$/);
});
for (const [status, reason] of [[404, 'product-not-configured'], [403, 'catalog-access-denied']]) {
  test(`catalog configuration error ${status} disables checkout with a safe reason`, async () => {
    const billing = createPlayBilling({
      enabled: () => true,
      request: async () => { throw {response: {status}}; },
    });
    assert.deepEqual(await billing.status(), {packageName, productId, ready: false, reason});
  });
}
test('catalog outages do not masquerade as a missing product', async () => {
  const billing = createPlayBilling({
    enabled: () => true,
    request: async () => { throw new Error('network unavailable'); },
  });
  await assert.rejects(billing.status(), /network unavailable/);
});
test('invalid tokens and caller-controlled product/package IDs are rejected', async () => {
  const {billing, calls} = setup();
  for (const input of [null, [], {}, {purchaseToken: ''},
    {purchaseToken: ' '}, {purchaseToken: 'a\nb'},
    {purchaseToken: 'x'.repeat(4097)}, {purchaseToken: 'token', productId: 'other'},
    {purchaseToken: 'token', packageName: 'other'}]) {
    await assert.rejects(billing.verify(input), BillingError);
  }
  assert.equal(calls.length, 0);
});
