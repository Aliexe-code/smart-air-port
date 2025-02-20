// src/modules/booking/services/payment.service.ts
import { Injectable, Logger } from '@nestjs/common';
import Stripe from 'stripe';
import { ConfigService } from '@nestjs/config';
import { EventBus } from 'src/common/event-bus.service';

type PaymentIntentParams = {
  amount: number;
  currency: string;
  paymentMethod: string;
  metadata: Record<string, any>;
};

@Injectable()
export class PaymentService {
  private stripe: Stripe;
  private readonly logger = new Logger(PaymentService.name);

  constructor(
    private configService: ConfigService,
    private eventBus: EventBus, // Only EventBus is injected
  ) {
    const stripeKey =
      this.configService.getOrThrow<string>('STRIPE_SECRET_KEY');
    this.stripe = new Stripe(stripeKey, { apiVersion: '2025-01-27.acacia' });
  }

  async createPaymentIntent(
    params: PaymentIntentParams,
  ): Promise<Stripe.PaymentIntent> {
    try {
      const paymentIntent = await this.stripe.paymentIntents.create({
        amount: params.amount,
        currency: params.currency,
        payment_method_types: [params.paymentMethod],
        metadata: params.metadata,
      });
      this.logger.log(`Payment intent created: ${paymentIntent.id}`);
      return paymentIntent;
    } catch (err: unknown) {
      const error = err instanceof Error ? err : new Error(String(err));
      this.logger.error(`Payment failed: ${error.message}`);
      throw new PaymentProcessingError('Payment processing failed');
    }
  }

  async confirmPayment(
    paymentIntentId: string,
    expectedAmount: number,
  ): Promise<void> {
    const paymentIntent =
      await this.stripe.paymentIntents.retrieve(paymentIntentId);
    if (paymentIntent.amount !== expectedAmount) {
      throw new PaymentProcessingError('Amount mismatch');
    }
    try {
      await this.stripe.paymentIntents.confirm(paymentIntentId);
    } catch (err: unknown) {
      const error = err instanceof Error ? err : new Error(String(err));
      this.logger.error(`Payment confirmation failed: ${error.message}`);
      throw new PaymentProcessingError('Payment confirmation failed');
    }
  }

  async handleWebhookEvent(payload: Buffer, signature: string): Promise<void> {
    try {
      const event = this.stripe.webhooks.constructEvent(
        payload,
        signature,
        this.configService.getOrThrow<string>('STRIPE_WEBHOOK_SECRET'),
      );

      switch (event.type) {
        case 'payment_intent.succeeded':
          this.logger.log('Payment succeeded');
          this.eventBus.publish('payment.succeeded', {
            paymentIntentId: event.data.object.id,
          });
          break;
        case 'payment_intent.payment_failed':
          this.logger.error('Payment failed');
          this.eventBus.publish('payment.failed', {
            paymentIntentId: event.data.object.id,
            reason: 'Payment failed',
          });
          break;
        default:
          this.logger.warn(`Unhandled event type: ${event.type}`);
      }
    } catch (err: unknown) {
      const error = err instanceof Error ? err : new Error(String(err));
      this.logger.error(`Webhook handling failed: ${error.message}`);
      throw new PaymentProcessingError('Webhook handling failed');
    }
    // Add a dummy await so that the function includes an await expression.
    await Promise.resolve();
  }

  async processRefund(paymentIntentId: string): Promise<void> {
    try {
      await this.stripe.refunds.create({ payment_intent: paymentIntentId });
    } catch (err: unknown) {
      const error = err instanceof Error ? err : new Error(String(err));
      this.logger.error(`Refund failed: ${error.message}`);
      throw new PaymentProcessingError('Refund processing failed');
    }
  }
}

export class PaymentProcessingError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'PaymentProcessingError';
  }
}
