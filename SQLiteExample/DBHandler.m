//
//  DBHandler.m
//  SQLiteExample
//
//  Created by Narendra Kumar on 3/23/16.
//  Copyright © 2016 Narendra. All rights reserved.
//

#import "DBHandler.h"
#import <sqlite3.h>

@implementation DBHandler{
    sqlite3 *database;

}
static NSString *databaseName=@"TslDb.sqlite";
+(DBHandler *)handler{
    
    static DBHandler *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    
    return _sharedClient;
}

-(NSString*)getDatabasePath{
    NSArray *directoriesArray=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath=[directoriesArray objectAtIndex:0];
    NSString *databasePath=[filePath stringByAppendingPathComponent:databaseName];
    return databasePath;
}
-(void)checkAndCreateDatabaseinDocumentDirectory{
    NSString *destinationPath=[self getDatabasePath];
    NSLog(@"destinationpath doc path=>%@",destinationPath);
    NSFileManager *filemanager=[NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:destinationPath]){
        return;
    }
    
    NSString *sourcePath=[[NSBundle mainBundle] pathForResource:databaseName ofType:nil] ;
    NSLog(@"sourcePath=>%@",sourcePath);
    [filemanager copyItemAtPath:sourcePath toPath:destinationPath error:nil];
    [self createTable];
}
-(void)createTable{
    [self openDatabase];
    sqlite3_stmt *statement;
    NSString *queryForCreateTable=[NSString stringWithFormat:@"CREATE TABLE Pair (objectId VARCHAR Primary key, fromId VARCHAR, toID VARCHAR, status VARCHAR, relation VARCHAR)"];
    
    
    if (sqlite3_prepare_v2(database, [queryForCreateTable UTF8String], -1, &statement, NULL)==SQLITE_OK)
    {
        if(SQLITE_DONE != sqlite3_step(statement)){
            NSLog(@"0, while creating database '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
    }
    
}

-(void)insertDataToPairTabel:(NSArray *)totalData
{

    if([self openDatabase]){
        sqlite3_exec(database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
        for (NSDictionary *eachRow in totalData) {
            NSString *objectId=[eachRow valueForKey:@"objectId"];
            NSString *fromId=[eachRow valueForKey:@"fromId"];
            NSString *paired=[[eachRow valueForKey:@"paired"] stringValue];
            NSString *relation=[eachRow valueForKey:@"relation"];
            NSString *toId=[eachRow valueForKey:@"toId"];

            sqlite3_stmt *statement = nil;

            if(statement == nil)
            {
                const char *queryString="insert into Pair(objectId, fromId, toID, status, relation)  values(?,?,?,?,?)";
                
                if(sqlite3_prepare_v2(database, queryString, -1, &statement, NULL) != SQLITE_OK)
                    NSLog(@"Error: Failed to prepare statement with message '%s'.",sqlite3_errmsg(database));
            }
            
            sqlite3_bind_text(statement, 1,[objectId UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2,[fromId UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3,[toId UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4,[paired UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5,[relation UTF8String],-1,SQLITE_TRANSIENT);
            
            if(SQLITE_DONE != sqlite3_step(statement)){
                NSLog(@"0, while inserting data. '%s'", sqlite3_errmsg(database));
            }
            
            sqlite3_reset(statement);
            
            
            
            
            if(statement)
                sqlite3_step(statement);
            sqlite3_finalize(statement);
            
            
        }
        
        if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
            NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
        sqlite3_close(database);
    }else{
        NSLog(@"Error :: Database Not Opened");
    }
    
}
-(NSArray *)readDataFromPairTabel{
    if([self openDatabase]){
        NSString *queryString=[NSString stringWithFormat:@"select * from Pair"];
        sqlite3_stmt *statement = nil;
        
        NSMutableArray * indexArray=[[NSMutableArray alloc]initWithObjects:@"objectId", @"fromId", @"toID", @"status", @"relation",nil];
        
        NSMutableArray *dataArray=[[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [queryString UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                NSMutableDictionary *recordData=[[NSMutableDictionary alloc]init];
                for ( int i=0; i<[indexArray count]; i++)
                {
                    const char *columnstr= (const char*)sqlite3_column_text(statement, i);
                    
                    NSString *columnStr=[NSString stringWithUTF8String:columnstr];
                    if (columnStr.length!=0)
                    {
                        [recordData setObject:columnStr forKey:[indexArray objectAtIndex:i]];
                    }else{
                        [recordData setObject:@"" forKey:[indexArray objectAtIndex:i]];
                    }
                    
                }
                
                [dataArray addObject:recordData];
            }
            
            return dataArray;
        }
    }
    else{
        NSLog(@"Error ::  %s Database Not Opened",__FUNCTION__);
    }
    return nil;
}
-(BOOL)openDatabase
{
    NSString *databasepath=[self getDatabasePath];
    
    if (sqlite3_open([databasepath UTF8String], &database)==SQLITE_OK)
    {
        return YES;
    }
    else {
        return NO;
    }
    
}
@end
