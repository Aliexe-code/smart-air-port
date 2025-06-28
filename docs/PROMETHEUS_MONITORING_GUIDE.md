# Smart Airport - Prometheus Monitoring Guide

## 🎯 What is Prometheus?

**Prometheus** is a powerful open-source monitoring and alerting system that collects metrics from your applications and infrastructure, stores them in a time-series database, and provides powerful querying capabilities.

### 🔍 Why Add Prometheus to Smart Airport?

- **📊 Real-time Monitoring** - Track application performance, errors, and usage
- **🚨 Intelligent Alerting** - Get notified when issues occur before users notice
- **📈 Performance Insights** - Understand traffic patterns, response times, and bottlenecks
- **🔧 Operational Excellence** - Make data-driven decisions about scaling and optimization

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                 Smart Airport Monitoring Stack             │
├─────────────────────────────────────────────────────────────┤
│  📈 Prometheus (Port 9090)                                │
│  ├─ Metrics Collection                                    │
│  ├─ Time Series Database                                  │
│  └─ Query Engine                                          │
├─────────────────────────────────────────────────────────────┤
│  🚨 AlertManager (Port 9093)  🔍 Node Exporter (Port 9100) │
│  ├─ Alert Routing            ├─ System Metrics            │
│  ├─ Email/Slack Notifications├─ CPU, Memory, Disk         │
│  └─ Alert Grouping           └─ Network Statistics        │
├─────────────────────────────────────────────────────────────┤
│              🛩️ Smart Airport Application                  │
│              ├─ /metrics endpoint (Prometheus format)      │
│              ├─ Business metrics (bookings, searches)      │
│              └─ Technical metrics (response time, errors)  │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Setup (5 minutes)

### Prerequisites
```bash
# Ensure Docker and Docker Compose are installed
docker --version
docker-compose --version
```

### 1. Start Monitoring Stack
```bash
# Navigate to project root
cd /home/uriel/smart-air-port

# Start complete monitoring stack
./monitoring/setup-monitoring.sh setup
```

### 2. Access Monitoring Tools
- **📈 Prometheus**: http://localhost:9090 (metrics and queries)
- **🚨 AlertManager**: http://localhost:9093 (alert management)
- **🔍 Node Exporter**: http://localhost:9100 (system metrics)

### 3. View Your Application Metrics
- **🛩️ Smart Airport Metrics**: http://localhost:3001/metrics
- **🏥 Health Check**: http://localhost:3001/health

## 📊 What You'll Monitor

### Application Metrics
- **HTTP Requests**: Total requests, response times, status codes
- **Business Metrics**: Flight searches, bookings, payments
- **Database Operations**: MongoDB queries, connection pool
- **Email Notifications**: Sent emails, delivery status
- **User Activity**: Active sessions, API usage patterns

### System Metrics
- **CPU Usage**: Per core and overall utilization
- **Memory Usage**: RAM consumption and availability
- **Disk Usage**: Storage space and I/O operations
- **Network**: Bandwidth usage and connection counts

### Custom Smart Airport Metrics
- **Flight Search Rate**: Searches per minute by route
- **Booking Success Rate**: Successful vs failed bookings
- **Payment Processing**: Payment methods and success rates
- **API Response Times**: Per endpoint performance
- **Error Rates**: 4xx and 5xx errors by endpoint

## 🛠️ Integration with Your Application

### 1. Install Dependencies
```bash
# Using Bun (recommended)
bun add @willsoto/nestjs-prometheus prom-client
bun add -D @types/prom-client

# Or using npm
npm install @willsoto/nestjs-prometheus prom-client
npm install -D @types/prom-client
```

### 2. Add Metrics Module to Your App
```typescript
// src/app.module.ts
import { MetricsModule } from './metrics/metrics.module';

@Module({
  imports: [
    // ... your existing imports
    MetricsModule,
  ],
  // ...
})
export class AppModule {}
```

### 3. Use Metrics in Your Services
```typescript
// Example: In your booking service
import { MetricsService } from '../metrics/metrics.service';

@Injectable()
export class BookingService {
  constructor(private metricsService: MetricsService) {}

  async createBooking(bookingData: any) {
    try {
      const booking = await this.bookingRepository.save(bookingData);
      
      // Record successful booking
      this.metricsService.incrementBookings('success', bookingData.paymentMethod);
      
      return booking;
    } catch (error) {
      // Record failed booking
      this.metricsService.incrementBookings('failed', bookingData.paymentMethod);
      throw error;
    }
  }
}
```

## 📈 Available Dashboards

### Smart Airport Overview Dashboard
- **Application Status**: Up/down status and health
- **Request Volume**: Requests per second over time
- **Response Times**: Average and 95th percentile response times
- **Error Rates**: 4xx and 5xx error percentages
- **Business Metrics**: Bookings, searches, payments

### System Performance Dashboard
- **CPU Usage**: Multi-core CPU utilization
- **Memory Usage**: RAM consumption and trends
- **Disk Usage**: Storage space and I/O metrics
- **Network**: Bandwidth and connection metrics

### Business Intelligence Dashboard
- **Flight Search Trends**: Popular routes and search patterns
- **Booking Analytics**: Success rates and payment methods
- **User Activity**: Active users and session duration
- **Revenue Metrics**: Payment volumes and trends

## 🚨 Alerting Rules

### Critical Alerts (Immediate Action Required)
- **Application Down**: Smart Airport not responding
- **High Error Rate**: >10% error rate for 2+ minutes
- **Database Down**: MongoDB connection lost
- **Low Disk Space**: <10% disk space remaining

### Warning Alerts (Monitor Closely)
- **High Response Time**: >2 seconds for 5+ minutes
- **High CPU Usage**: >80% for 5+ minutes
- **High Memory Usage**: >85% for 5+ minutes
- **Redis Down**: Cache service unavailable

### Business Alerts
- **Low Booking Success Rate**: <90% success rate
- **Payment Failures**: High payment failure rate
- **API Rate Limiting**: Approaching rate limits

## 🔧 Management Commands

### Start/Stop Monitoring
```bash
# Start monitoring stack
./monitoring/setup-monitoring.sh start

# Stop monitoring stack
./monitoring/setup-monitoring.sh stop

# Restart monitoring stack
./monitoring/setup-monitoring.sh restart

# Check status
./monitoring/setup-monitoring.sh status

# View logs
./monitoring/setup-monitoring.sh logs
```

### Docker Commands
```bash
# Start with Docker Compose
cd monitoring
docker-compose up -d

# View running services
docker-compose ps

# View logs
docker-compose logs -f prometheus

# Stop services
docker-compose down
```

### Kubernetes Deployment
```bash
# Deploy to Kubernetes
kubectl apply -f kubernetes/prometheus-stack.yaml

# Check status
kubectl get pods -l app=prometheus

# Access services
kubectl port-forward service/prometheus-service 9090:9090
```

## 📊 Key Metrics to Watch

### Performance Metrics
```promql
# Average response time
rate(smart_airport_http_request_duration_seconds_sum[5m]) / rate(smart_airport_http_request_duration_seconds_count[5m])

# Request rate
rate(smart_airport_http_requests_total[5m])

# Error rate
rate(smart_airport_http_requests_total{status_code=~"5.."}[5m]) / rate(smart_airport_http_requests_total[5m])
```

### Business Metrics
```promql
# Booking rate
rate(smart_airport_bookings_total[5m])

# Flight search rate
rate(smart_airport_flight_searches_total[5m])

# Payment success rate
rate(smart_airport_payments_total{status="success"}[5m]) / rate(smart_airport_payments_total[5m])
```

### System Metrics
```promql
# CPU usage
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk usage
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100
```

## 🎯 Benefits for Smart Airport

### For Development
- **🐛 Faster Debugging**: Identify performance bottlenecks quickly
- **📊 Data-Driven Decisions**: Optimize based on real usage patterns
- **🔍 Proactive Monitoring**: Catch issues before they affect users

### For Operations
- **🚨 Early Warning System**: Get alerted before problems escalate
- **📈 Capacity Planning**: Understand when to scale resources
- **📋 SLA Monitoring**: Track uptime and performance targets

### For Business
- **💰 Revenue Insights**: Monitor booking and payment trends
- **👥 User Behavior**: Understand how users interact with your app
- **🎯 Feature Usage**: See which features are most popular

## 🔧 Troubleshooting

### Common Issues
```bash
# Prometheus not scraping metrics
curl http://localhost:3001/metrics  # Check if metrics endpoint works
docker logs smart-airport-prometheus  # Check Prometheus logs

# Prometheus queries not working
# Check Prometheus configuration and targets

# Alerts not firing
# Check AlertManager configuration and email settings
```

### Useful Commands
```bash
# Check if metrics endpoint is working
curl http://localhost:3001/metrics

# Test Prometheus query
curl 'http://localhost:9090/api/v1/query?query=up'

# Check AlertManager status
curl http://localhost:9093/api/v1/status
```

## 🎉 Next Steps

1. **✅ Set up monitoring** using the setup script
2. **📊 Explore Prometheus queries** to understand your application metrics
3. **🚨 Configure alerts** for your specific needs
4. **📈 Add custom metrics** for business-specific monitoring
5. **🔧 Optimize performance** based on monitoring insights

**🚀 Your Smart Airport application now has enterprise-grade monitoring!**
