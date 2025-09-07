import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/order_model.dart';

class AppwriteService {
  static const String projectId = '68bbbcb6000730529db2'; // Replace with your Appwrite project ID
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1'; // Or your self-hosted endpoint

  static late Client client;
  static late Account account;
  static late Databases databases;
  static late Storage storage;

  static const String databaseId = '68bbbd4e0025e2dd2268'; // Replace with your database ID
  static const String usersCollectionId = 'users'; // Collection ID for users
  static const String shopsCollectionId = '68bbd17d0009df4b552d'; // Collection ID for shops
  static const String productsCollectionId = '68bbcf6800385fb2da69'; // Collection ID for products
  static const String ordersCollectionId = '68bbcbfc002ec6cfbb08'; // Collection ID for orders
  static const String imagesBucketId = '68bd2be60010ae4d0546'; // Bucket ID for product images

  static void init() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // Authentication methods
  static Future<User> signUp(String email, String password, String name) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Save additional user data to collection
      try {
        await databases.createDocument(
          databaseId: databaseId,
          collectionId: usersCollectionId,
          documentId: user.$id,
          data: {
            'email': email,
            'name': name,
            'createdAt': DateTime.now().toIso8601String(),
            'isSeller': true, // Assuming this is for sellers
          },
        );
        print('User data saved successfully for user: ${user.$id}');
      } catch (e) {
        print('Failed to save user data: $e');
        // Don't throw here, user is created but data not saved
        // This allows the signup to succeed even if collection doesn't exist
      }

      return user;
    } catch (e) {
      print('Signup failed: $e');
      throw Exception('Signup failed: $e');
    }
  }

  static Future<Session> signIn(String email, String password) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Check if user data exists in collection
      try {
        await databases.getDocument(
          databaseId: databaseId,
          collectionId: usersCollectionId,
          documentId: session.userId,
        );
        print('User data exists for user: ${session.userId}');
      } catch (e) {
        print('User data does not exist, creating: $e');
        // If user data doesn't exist, create it
        final user = await account.get();
        try {
          await databases.createDocument(
            databaseId: databaseId,
            collectionId: usersCollectionId,
            documentId: session.userId,
            data: {
              'email': user.email,
              'name': user.name,
              'createdAt': DateTime.now().toIso8601String(),
              'isSeller': true,
            },
          );
          print('User data created successfully for user: ${session.userId}');
        } catch (createError) {
          print('Failed to create user data: $createError');
          // Continue without throwing, user is logged in
        }
      }

      return session;
    } catch (e) {
      print('Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final document = await databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );
      print('User data retrieved for user: $userId');
      return document.data;
    } catch (e) {
      print('Failed to get user data for $userId: $e');
      return null;
    }
  }

  static Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: data,
      );
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  // Shop methods
  static Future<Shop> createShop(Shop shop) async {
    try {
      final document = await databases.createDocument(
        databaseId: databaseId,
        collectionId: shopsCollectionId,
        documentId: ID.unique(),
        data: shop.toJson(),
      );
      return Shop.fromJson(document.data);
    } catch (e) {
      throw Exception('Failed to create shop: $e');
    }
  }

  static Future<List<Shop>> getShopsBySeller(String sellerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: shopsCollectionId,
        queries: [
          Query.equal('sellerId', sellerId),
        ],
      );
      return response.documents.map((doc) => Shop.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to get shops: $e');
    }
  }

  static Future<Shop?> getShopBySlug(String slug) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: shopsCollectionId,
        queries: [
          Query.equal('slug', slug),
        ],
      );
      if (response.documents.isNotEmpty) {
        return Shop.fromJson(response.documents.first.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get shop: $e');
    }
  }

  static Future<Shop?> getShopById(String shopId) async {
    try {
      final document = await databases.getDocument(
        databaseId: databaseId,
        collectionId: shopsCollectionId,
        documentId: shopId,
      );
      return Shop.fromJson(document.data);
    } catch (e) {
      return null;
    }
  }

  static Future<Shop?> getCurrentUserShop() async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return null;
      }

      final shops = await getShopsBySeller(user.$id);
      return shops.isNotEmpty ? shops.first : null;
    } catch (e) {
      print('Failed to get current user shop: $e');
      return null;
    }
  }

  static Future<void> updateShop(String shopId, Map<String, dynamic> data) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: shopsCollectionId,
        documentId: shopId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update shop: $e');
    }
  }

  // Product methods
  static Future<Product> createProduct(Product product) async {
    try {
      final document = await databases.createDocument(
        databaseId: databaseId,
        collectionId: productsCollectionId,
        documentId: ID.unique(),
        data: product.toJson(),
      );
      return Product.fromJson(document.data);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  static Future<List<Product>> getProductsByShop(String shopId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: productsCollectionId,
        queries: [
          Query.equal('shopId', shopId),
          Query.equal('isActive', true),
        ],
      );
      return response.documents.map((doc) => Product.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  static Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: productsCollectionId,
        queries: [
          Query.equal('sellerId', sellerId),
        ],
      );
      return response.documents.map((doc) => Product.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  static Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: productsCollectionId,
        documentId: productId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: productsCollectionId,
        documentId: productId,
      );
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Image upload methods
  static Future<String> uploadProductImage(PlatformFile imageFile, String fileName) async {
    try {
      final file = await storage.createFile(
        bucketId: imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: imageFile.bytes!,
          filename: fileName,
        ),
      );
      return file.$id;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<List<String>> uploadMultipleProductImages(List<PlatformFile> imageFiles) async {
    List<String> uploadedFileIds = [];
    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = 'product_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final fileId = await uploadProductImage(file, fileName);
        uploadedFileIds.add(fileId);
      }
      return uploadedFileIds;
    } catch (e) {
      // If upload fails, delete any already uploaded images
      for (String fileId in uploadedFileIds) {
        try {
          await deleteProductImage(fileId);
        } catch (deleteError) {
          print('Failed to delete image $fileId: $deleteError');
        }
      }
      throw Exception('Failed to upload images: $e');
    }
  }

  static Future<String> getProductImageUrl(String fileId) async {
    // Generate URL manually using the correct format
    return 'https://fra.cloud.appwrite.io/v1/storage/buckets/$imagesBucketId/files/$fileId/view?project=$projectId';
  }

  static Future<List<String>> getProductImageUrls(List<String> fileIds) async {
    List<String> urls = [];
    for (String fileId in fileIds) {
      final url = await getProductImageUrl(fileId);
      urls.add(url);
    }
    return urls;
  }

  static Future<void> deleteProductImage(String fileId) async {
    try {
      await storage.deleteFile(
        bucketId: imagesBucketId,
        fileId: fileId,
      );
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  static Future<void> deleteMultipleProductImages(List<String> fileIds) async {
    for (String fileId in fileIds) {
      try {
        await deleteProductImage(fileId);
      } catch (e) {
        print('Failed to delete image $fileId: $e');
      }
    }
  }

  // Order methods
  static Future<Order> createOrder(Order order) async {
    try {
      // Validate required fields
      if (order.customerId.isEmpty || order.sellerId.isEmpty || order.shopId.isEmpty) {
        throw Exception('Missing required order information (customer, seller, or shop data)');
      }

      final document = await databases.createDocument(
        databaseId: databaseId,
        collectionId: ordersCollectionId,
        documentId: ID.unique(),
        data: order.toJson(),
      );
      return Order.fromJson(document.data);
    } catch (e) {
      print('Failed to create order: $e');
      if (e.toString().contains('shop')) {
        throw Exception('Shop information is invalid or shop does not exist');
      }
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<List<Order>> getOrdersBySeller(String sellerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: ordersCollectionId,
        queries: [
          Query.equal('sellerId', sellerId),
        ],
      );
      return response.documents.map((doc) => Order.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  static Future<List<Order>> getOrdersByCustomer(String customerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: ordersCollectionId,
        queries: [
          Query.equal('customerId', customerId),
        ],
      );
      return response.documents.map((doc) => Order.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: ordersCollectionId,
        documentId: orderId,
        data: {
          'status': status,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  static Future<Order?> getOrderById(String orderId) async {
    try {
      final document = await databases.getDocument(
        databaseId: databaseId,
        collectionId: ordersCollectionId,
        documentId: orderId,
      );
      return Order.fromJson(document.data);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> validateShopExists(String shopId) async {
    try {
      await databases.getDocument(
        databaseId: databaseId,
        collectionId: shopsCollectionId,
        documentId: shopId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
