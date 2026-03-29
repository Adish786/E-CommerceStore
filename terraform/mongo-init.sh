#!/bin/bash

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
until mongosh --eval "db.version()" > /dev/null 2>&1; do
  echo "MongoDB is unavailable - sleeping..."
  sleep 2
done

echo "MongoDB is ready! Creating databases and collections..."

# Create databases and collections
mongosh <<EOF
// Switch to admin database
use admin;

// Create user database
use ecommerce_users;
db.createCollection("users");
db.users.createIndex({ email: 1 }, { unique: true });
print("✅ ecommerce_users database created");

// Create product database
use ecommerce_products;
db.createCollection("products");
db.products.createIndex({ category: 1 });
db.createCollection("categories");
print("✅ ecommerce_products database created");

// Create cart database
use ecommerce_carts;
db.createCollection("carts");
db.carts.createIndex({ userId: 1 }, { unique: true });
print("✅ ecommerce_carts database created");

// Create order database
use ecommerce_orders;
db.createCollection("orders");
db.orders.createIndex({ userId: 1 });
db.orders.createIndex({ createdAt: -1 });
print("✅ ecommerce_orders database created");

print("\n✅ All databases initialized successfully!");
EOF

echo "Database initialization complete!"
