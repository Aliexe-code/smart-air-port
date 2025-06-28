// src/metrics/metrics.service.ts
import { Injectable } from '@nestjs/common';
import { InjectMetric } from '@willsoto/nestjs-prometheus';
import { Counter, Histogram, Gauge } from 'prom-client';

@Injectable()
export class MetricsService {
  constructor(
    @InjectMetric('smart_airport_http_requests_total')
    private readonly httpRequestsTotal: Counter<string>,
    
    @InjectMetric('smart_airport_http_request_duration_seconds')
    private readonly httpRequestDuration: Histogram<string>,
    
    @InjectMetric('smart_airport_active_connections')
    private readonly activeConnections: Gauge<string>,
    
    @InjectMetric('smart_airport_flight_searches_total')
    private readonly flightSearchesTotal: Counter<string>,
    
    @InjectMetric('smart_airport_bookings_total')
    private readonly bookingsTotal: Counter<string>,
    
    @InjectMetric('smart_airport_payments_total')
    private readonly paymentsTotal: Counter<string>,
    
    @InjectMetric('smart_airport_database_operations_total')
    private readonly databaseOperationsTotal: Counter<string>,
    
    @InjectMetric('smart_airport_email_notifications_total')
    private readonly emailNotificationsTotal: Counter<string>,
  ) {}

  // HTTP Request metrics
  incrementHttpRequests(method: string, route: string, statusCode: string) {
    this.httpRequestsTotal.inc({
      method,
      route,
      status_code: statusCode,
    });
  }

  recordHttpRequestDuration(method: string, route: string, duration: number) {
    this.httpRequestDuration.observe(
      {
        method,
        route,
      },
      duration,
    );
  }

  // Connection metrics
  setActiveConnections(count: number) {
    this.activeConnections.set(count);
  }

  incrementActiveConnections() {
    this.activeConnections.inc();
  }

  decrementActiveConnections() {
    this.activeConnections.dec();
  }

  // Business metrics
  incrementFlightSearches(origin?: string, destination?: string) {
    this.flightSearchesTotal.inc({
      origin: origin || 'unknown',
      destination: destination || 'unknown',
    });
  }

  incrementBookings(status: string, paymentMethod?: string) {
    this.bookingsTotal.inc({
      status,
      payment_method: paymentMethod || 'unknown',
    });
  }

  incrementPayments(method: string, status: string, amount?: number) {
    this.paymentsTotal.inc({
      method,
      status,
      amount_range: this.getAmountRange(amount),
    });
  }

  incrementDatabaseOperations(operation: string, collection: string, status: string) {
    this.databaseOperationsTotal.inc({
      operation,
      collection,
      status,
    });
  }

  incrementEmailNotifications(type: string, status: string) {
    this.emailNotificationsTotal.inc({
      type,
      status,
    });
  }

  private getAmountRange(amount?: number): string {
    if (!amount) return 'unknown';
    if (amount < 100) return '0-100';
    if (amount < 500) return '100-500';
    if (amount < 1000) return '500-1000';
    if (amount < 5000) return '1000-5000';
    return '5000+';
  }
}
