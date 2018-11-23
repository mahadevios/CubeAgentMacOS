//
//  NSData+AES256.m
//  Communicator
//
//  Created by mac on 17/11/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//
// http://robnapier.net/aes-commoncrypto

#import "NSData+AES256.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

@implementation NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128]; // room for terminator (unused)
    char IVPtr[kCCKeySizeAES128];
    bzero(IVPtr, sizeof(IVPtr)); // fill with zeroes (for padding)

    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    [key getCString:IVPtr maxLength:sizeof(IVPtr) encoding:NSUTF8StringEncoding];

   // [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          IVPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128]; // room for terminator (unused)
    char IVPtr[kCCKeySizeAES128];
    bzero(IVPtr, sizeof(IVPtr)); // fill with zeroes (for padding)
    
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    [key getCString:IVPtr maxLength:sizeof(IVPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          IVPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}
NSString * const
kRNCryptManagerErrorDomain = @"net.robnapier.RNCryptManager";

//const CCAlgorithm kAlgorithm = kCCAlgorithmAES128;
//const NSUInteger kAlgorithmKeySize = kCCKeySizeAES128;
//const NSUInteger kAlgorithmBlockSize = kCCBlockSizeAES128;
//const NSUInteger kAlgorithmIVSize = kCCBlockSizeAES128;
const CCAlgorithm kAlgorithm = kCCAlgorithmAES128;
const NSUInteger kAlgorithmKeySize = 32;
const NSUInteger kAlgorithmBlockSize = 16;
//const NSUInteger kAlgorithmIVSize = kCCBlockSizeAES128;
//const NSUInteger kPBKDFSaltSize = 8;
//const NSUInteger kPBKDFRounds = 10000;  // ~80ms on an iPhone 4

// ===================

+ (NSData *)encryptedDataForData:(NSData *)data
                        password:(NSString *)password
                              iv:(NSData **)iv
                            salt:(NSData **)salt
                           error:(NSError **)error {
    NSAssert(iv, @"IV must not be NULL");
    NSAssert(salt, @"salt must not be NULL");
    
    
    //*iv = [self randomDataOfLength:kAlgorithmIVSize];
    //*salt = [self randomDataOfLength:kPBKDFSaltSize];
    
//    NSData *key = [self AESKeyForPassword:password salt:*salt];
    NSData *key = [self test_doKeyForPassword];

    size_t outLength;
    NSMutableData *
    cipherData = [NSMutableData dataWithLength:data.length +
                  kAlgorithmBlockSize];
    
    CCCryptorStatus
    result = CCCrypt(kCCEncrypt, // operation
                     kAlgorithm, // Algorithm
                     kCCOptionPKCS7Padding, // options
                     key.bytes, // key
                     key.length, // keylength
                     (*iv).bytes,// iv
                     data.bytes, // dataIn
                     data.length, // dataInLength,
                     cipherData.mutableBytes, // dataOut
                     cipherData.length, // dataOutAvailable
                     &outLength); // dataOutMoved
    
    if (result == kCCSuccess) {
        cipherData.length = outLength;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:kRNCryptManagerErrorDomain
                                         code:result
                                     userInfo:nil];
        }
        return nil;
    }
    
    return cipherData;
}

+ (NSData *)decryptedDataForData:(NSData *)data
                        password:(NSString *)password
                              iv:(NSData **)iv
                            salt:(NSData **)salt
                           error:(NSError **)error {
    NSAssert(iv, @"IV must not be NULL");
    NSAssert(salt, @"salt must not be NULL");
    
    
    //*iv = [self randomDataOfLength:kAlgorithmIVSize];
    //*salt = [self randomDataOfLength:kPBKDFSaltSize];
    
//    NSData *key = [self AESKeyForPassword:password salt:*salt];
    NSData *key = [self test_doKeyForPassword];

    size_t outLength;
    NSMutableData *
    cipherData = [NSMutableData dataWithLength:data.length +
                  kAlgorithmBlockSize];
    
    CCCryptorStatus
    result = CCCrypt(kCCDecrypt, // operation
                     kAlgorithm, // Algorithm
                     kCCOptionPKCS7Padding, // options
                     key.bytes, // key
                     key.length, // keylength
                     (*iv).bytes,// iv
                     data.bytes, // dataIn
                     data.length, // dataInLength,
                     cipherData.mutableBytes, // dataOut
                     cipherData.length, // dataOutAvailable
                     &outLength); // dataOutMoved
    
    if (result == kCCSuccess) {
        cipherData.length = outLength;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:kRNCryptManagerErrorDomain
                                         code:result
                                     userInfo:nil];
        }
        return nil;
    }
    
    return cipherData;
}

// ===================

+ (NSData *)randomDataOfLength:(size_t)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    int result = SecRandomCopyBytes(kSecRandomDefault,
                                    length,
                                    data.mutableBytes);
    NSAssert(result == 0, @"Unable to generate random bytes: %d",
             errno);
    
    return data;
}

// ===================

// Replace this with a 10,000 hash calls if you don't have CCKeyDerivationPBKDF
//+ (NSData *)AESKeyForPassword:(NSString *)password
//                         salt:(NSData *)salt {
//    NSMutableData *
//    derivedKey = [NSMutableData dataWithLength:kAlgorithmKeySize];
//
//    int
//    result = CCKeyDerivationPBKDF(kCCPBKDF2,            // algorithm
//                                  password.UTF8String,  // password
//                                  [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],  // passwordLength
//                                  salt.bytes,           // salt
//                                  salt.length,          // saltLen
//                                  kCCPRFHmacAlgSHA1,    // PRF
//                                  kPBKDFRounds,         // rounds
//                                  derivedKey.mutableBytes, // derivedKey
//                                  derivedKey.length); // derivedKeyLen
//
//    // Do not log password here
//    NSAssert(result == kCCSuccess,
//             @"Unable to create AES key for password: %d", result);
//
//    return derivedKey;
//}
+ (NSData *)AESKeyForPassword:(NSString *)password
                         salt:(NSData *)salt {
    NSMutableData *
    derivedKey = [NSMutableData dataWithLength:kAlgorithmKeySize];
    
    uint    keySize = kCCKeySizeAES256;
    
    NSMutableData *derived = [NSMutableData dataWithLength:keySize];
    
    int
    result = CCKeyDerivationPBKDF(kCCPBKDF2,            // algorithm
                                  password.UTF8String,  // password
                                  [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],  // passwordLength
                                  salt.bytes,           // salt
                                  salt.length,          // saltLen
                                  kCCHmacAlgMD5,    // PRF
                                  2,         // rounds
                                  derivedKey.mutableBytes, // derivedKey
                                  derivedKey.length); // derivedKeyLen
    
    // Do not log password here
    NSAssert(result == kCCSuccess,
             @"Unable to create AES key for password: %d", result);
    
    return derivedKey;
}
+ (NSData *)doSha256:(NSData *)dataIn
{
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_MD5_DIGEST_LENGTH];
//    CC_SHA256(dataIn.bytes, dataIn.length, macOut.mutableBytes);
   

    NSString * parameters = @"string to hash";
    NSString *salt = @"saltStringHere";
    NSData *saltData = [salt dataUsingEncoding:NSUTF8StringEncoding];
    NSData *paramData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, paramData.bytes, paramData.length, hash.mutableBytes);
    NSString *base64Hash = [hash base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return macOut;
}


+ (NSData *)doKeyForPassword:(NSString *)password
                        salt:(NSData *)salt
                     keySize:(NSUInteger)keySize
                      rounds:(NSUInteger)rounds
{
    NSMutableData *derivedKey = [NSMutableData dataWithLength:keySize];
    
    NSData *passwordData = [password dataUsingEncoding: NSUTF8StringEncoding];
    
    CCKeyDerivationPBKDF(kCCPBKDF2, // algorithm
                         password.UTF8String,               // password
                         passwordData.length,              // passwordLength
                         salt.bytes,                // salt
                         salt.length,               // saltLen
                         kCCHmacAlgMD5,         // PRF
                         2,                    // rounds
                         derivedKey.mutableBytes,   // derivedKey
                         derivedKey.length);        // derivedKeyLen
    
    return derivedKey;
}

+ (NSData*)test_doKeyForPassword
{
    NSData *key = [NSData doKeyForPassword:@"password" salt:[@"s@1tValue" dataUsingEncoding:NSUTF8StringEncoding] keySize:kCCKeySizeAES256 rounds:2];

    return key;
}
@end
