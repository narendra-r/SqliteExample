//
//  DBHandler.h
//  SQLiteExample
//
//  Created by Narendra Kumar on 3/23/16.
//  Copyright © 2016 Narendra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHandler : NSObject
+(DBHandler *)handler;
-(void)checkAndCreateDatabaseinDocumentDirectory;
-(void)insertDataToPairTabel:(NSArray *)totalData;
-(NSArray *)readDataFromPairTabel;
@end
