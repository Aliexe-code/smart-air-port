// MongoDB initialization script for Smart Airport
// This script runs when the MongoDB container starts for the first time

// Switch to the smartairport database
db = db.getSiblingDB('smartairport');

// Create application user with read/write permissions
db.createUser({
  user: 'smartairport_user',
  pwd: 'smartairport_pass',
  roles: [
    {
      role: 'readWrite',
      db: 'smartairport'
    }
  ]
});

// Create initial collections with indexes for better performance
db.createCollection('users');
db.createCollection('bookings');
db.createCollection('flights');
db.createCollection('payments');
db.createCollection('notifications');

// Create indexes for better query performance
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "phone": 1 });
db.bookings.createIndex({ "userId": 1 });
db.bookings.createIndex({ "bookingReference": 1 }, { unique: true });
db.bookings.createIndex({ "status": 1 });
db.bookings.createIndex({ "createdAt": 1 });
db.flights.createIndex({ "flightNumber": 1 });
db.flights.createIndex({ "departure.date": 1 });
db.flights.createIndex({ "origin": 1, "destination": 1 });
db.payments.createIndex({ "bookingId": 1 });
db.payments.createIndex({ "paymentId": 1 }, { unique: true });
db.payments.createIndex({ "status": 1 });
db.notifications.createIndex({ "userId": 1 });
db.notifications.createIndex({ "createdAt": 1 });

print('Smart Airport database initialized successfully!');
print('Created user: smartairport_user');
print('Created collections with indexes for optimal performance');
