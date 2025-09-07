# Appwrite Hack - E-commerce Platform

A modern Flutter e-commerce application built with Appwrite backend services.

## Features

- 🔐 User Authentication (Signup/Login)
- 🏪 Shop Creation and Management
- 📦 Product Management
- 📋 Order Management
- 🛒 Customer Storefront
- 🎨 Beautiful UI with Multiple Themes

## Setup Instructions

### 1. Appwrite Setup

1. Create a new project on [Appwrite Cloud](https://cloud.appwrite.io) or your self-hosted instance
2. Note your Project ID and API Endpoint
3. Update the configuration in `lib/services/appwrite_service.dart`:
   ```dart
   static const String projectId = 'your-project-id';
   static const String endpoint = 'https://your-endpoint/v1';
   static const String databaseId = 'your-database-id';
   ```

### 2. Database Collections Setup

Create the following collections in your Appwrite database:

#### Users Collection
- **Collection ID**: `users`
- **Attributes**:
  - `email` (string, required)
  - `name` (string, required)
  - `isSeller` (boolean, default: false)
  - `createdAt` (datetime, required)
  - `phone` (string, optional)
  - `avatarUrl` (string, optional)

#### Shops Collection
- **Collection ID**: `shops`
- **Attributes**:
  - `name` (string, required)
  - `slug` (string, required)
  - `description` (string, optional)
  - `email` (string, required)
  - `phone` (string, optional)
  - `sellerId` (string, required)
  - `theme` (string, default: "Midnight Pro")
  - `isActive` (boolean, default: true)
  - `createdAt` (datetime, required)
  - `logoUrl` (string, optional)
  - `bannerUrl` (string, optional)

#### Products Collection
- **Collection ID**: `products`
- **Attributes**:
  - `name` (string, required)
  - `description` (string, optional)
  - `price` (number, required, min: 0)
  - `salePrice` (number, optional, min: 0)
  - `category` (string, required)
  - `images` (string array, optional)
  - `sellerId` (string, required)
  - `shopId` (string, required)
  - `stock` (integer, optional, min: 0, default: 0)
  - `isActive` (boolean, optional, default: true)
  - `createdAt` (datetime, required)
  - `sku` (string, optional)
  - `weight` (number, optional, min: 0)

#### Orders Collection
- **Collection ID**: `orders`
- **Attributes**:
  - `customerId` (string, required)
  - `sellerId` (string, required)
  - `shopId` (string, required)
  - `items` (string, required) - JSON string of order items
  - `total` (number, required, min: 0)
  - `status` (string, optional, default: "Pending")
  - `createdAt` (datetime, required)
  - `customerName` (string, optional)
  - `customerEmail` (string, optional)
  - `customerPhone` (string, optional)
  - `paymentMethod` (string, optional)

### 3. Permissions Setup

For each collection, set the following permissions:
- **Read**: `role:all` (public read access)
- **Write**: `role:all` (public write access for demo purposes)

*Note: In production, you should set more restrictive permissions based on user roles.*

### 4. Flutter Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## App Structure

```
lib/
├── models/           # Data models
│   ├── user_model.dart
│   ├── shop_model.dart
│   ├── product_model.dart
│   └── order_model.dart
├── services/         # Appwrite service layer
│   └── appwrite_service.dart
├── features/         # Feature-based architecture
│   ├── auth/         # Authentication screens
│   ├── buyer/        # Customer-facing screens
│   ├── seller/       # Seller dashboard screens
│   └── routing/      # App routing
└── widgets/          # Reusable UI components
```

## Key Features Implemented

### Authentication
- User registration and login
- Session management
- Profile management

### Shop Management
- Create shops with custom themes
- Shop preview functionality
- Shop settings and branding

### Product Management
- Add/edit products
- Product categorization
- Stock management
- Image uploads

### Order Management
- View orders by seller
- Order status updates
- Order details and timeline

### Customer Experience
- Browse shops by slug
- View products
- Responsive design

## Technologies Used

- **Flutter**: Cross-platform mobile development
- **Appwrite**: Backend-as-a-Service
- **Riverpod**: State management
- **Material Design**: UI components

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
