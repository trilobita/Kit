//
//  Database.m
//  FitMe
//
//  Created by PC-wzj on 17/2/9.
//  Copyright © 2017年 方得. All rights reserved.
//

#import "Database.h"

@implementation Database
{
    //全局数据库操作对象
    FMDatabase *_database;
    //线程锁
    NSLock *_lock;
}

- (instancetype)init {
    if (self = [super init]) {
        
        NSString *temp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path =[NSString stringWithFormat:@"%@/data.sqlite", temp];
        NSLog(@"path = %@", path);
        //初始化数据库对象
        _database = [FMDatabase databaseWithPath:path];
        
        //初始化线程锁对象
        _lock = [[NSLock alloc] init];
        
        //创建表
        [self createDatabase];
        
    }
    
    return self;
}

- (void) createDatabase {
    
    NSString *sql;
    
    //创建用户表
    sql = @"CREATE TABLE IF NOT EXISTS userinfo (userid VARCHAR(20)  PRIMARY KEY, phone VARCHAR(20), password VARCHAR(20), islogin INTGER, isplay INTEGER)";
    [self updateWithSql:sql];
    
    //创建卡片信息表
    sql = @"CREATE TABLE IF NOT EXISTS messagejson (id INTEGER PRIMARY KEY AUTOINCREMENT, userid VARCHAR(20), message TEXT, messageid VARCHAR(30), date VARCHAR(30))";
    [self updateWithSql:sql];
}

//更新数据库表操作方法
- (BOOL)updateWithSql:(NSString *)sql {
    [_lock lock];
    [_database open];
    
    BOOL status = [_database executeUpdate:sql];
    NSLog(@"数据库SQL语句： %@", sql);
    [_database close];
    [_lock unlock];
    return status;
}


/**
 根据sql命令插入数据库

 @param sql sql插入数据语句
 @return 插入结果
 */
- (BOOL)insertDataWithSql:(NSString *)sql {
    return [self updateWithSql:sql];
}

/**
 插入数据操作

 @param table 插入目标表
 @param keys 对应字段名
 @param values 对应字段值
 @return 操作结果
 */
- (BOOL) insertDataToTable:(NSString *)table withKeys:(NSArray *)keys andValues:(NSArray *)values {
  
    NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO %@ (", table];
    
    for (int i = 0; i < [keys count]; i++) {
        if (i) {
            [sql appendString:[NSString stringWithFormat:@",%@", keys[i]]];
        } else {
            [sql appendString:keys[i]];
        }
    }
    [sql appendString:@") VALUES ("];
    
    for (int i = 0; i < [values count]; i++) {
        NSString *temp = [NSString stringWithFormat:@"%@", values[i]];
        if (i) {
            [sql appendString:[NSString stringWithFormat:@",%@", temp]];
        } else {
            [sql appendString:temp];
        }
    }
    [sql appendString:@")"];
    
    BOOL status = [self updateWithSql:sql];
    
    return status;
}


/**
 查询操作方法

 @param sql 查询语句
 @return 查询结果集
 */
- (FMResultSet *)selectDataWithSql:(NSString *)sql {
    [_lock lock];
    [_database open];
    
    FMResultSet *set = [_database executeQuery:sql];
    
    NSLog(@"数据库查询结果%d", [set columnCount]);
    @try {
        if ([self.delegate respondsToSelector:@selector(selectDatabaseDelegate:)]) {
            [self.delegate selectDatabaseDelegate:set];
        }
    } @catch (NSException *exception) {
        NSLog(@"数据库抛错：%@", exception);
    }
    
    [_database close];
    [_lock unlock];
    return set;
}

/**
 数据库查询操作
 
 @param sql 查询语句
 @param set 结果集block
 */
- (void) selectDataWithSql:(NSString *)sql resultSet:(ResultSet)set {
    [_lock lock];
    [_database open];
    
    FMResultSet *rs = [_database executeQuery:sql];
    set(rs);
    
    [_database close];
    [_lock unlock];
}

/**
 更新数据方法

 @param table 更新对象表
 @param keyValue 更新键值
 @param condition 更新条件
 @return 更新结果
 */
- (BOOL) updateWithTable:(NSString *)table setKeyValue:(NSDictionary *)keyValue whereCondition:(NSString *)condition {
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", table];
    BOOL flag = YES;
    for (NSString *key in [keyValue allKeys]) {
        NSString *value = [keyValue valueForKey:key];
        if (flag) {
            [sql appendFormat:@"%@ = %@", key, value];
            flag = !flag;
        } else {
            [sql appendFormat:@",%@ = %@", key, value];
        }
    }
    
    if (condition) {
        [sql appendFormat:@" WHERE %@", condition];
    }
    
    return [self updateWithSql:sql];
}

- (BOOL) updateWithTable:(NSString *)table keys:(NSArray *)keys setValues:(NSArray *)values whereCondition:(NSString *)condition {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", table];
    
    for (int i = 0; i < [keys count]; i++) {
        if (i) {
            [sql appendFormat:@",%@ = %@", keys[i], values[i]];
        } else {
            [sql appendFormat:@"%@ = %@", keys[i], values[i]];
        }
    }
    
    if (condition) {
        [sql appendFormat:@" WHERE %@", condition];
    }
    
    return [self updateWithSql:sql];
}

/**
 根据sql语句删除数据

 @param sql 删除数据的sql语句
 @return 返回数据库操作结果YES操作成功，NO操作失败
 */
- (BOOL) deleteDataWithSql:(NSString *) sql{
    return [self updateWithSql:sql];
}

/**
 数据库删除数据操作方法（condition = null 时删除表中所有数据）

 @param table 删除数据的目标表
 @param condition 删除条件
 @return 数据库操作结果YES操作成功，NO操作失败
 */
- (BOOL) deleteDataWithTable:(NSString *)table where:(NSString *)condition {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@", table];
    
    if (condition) {
        [sql appendFormat:@" WHERE %@", condition];
    }
    
    return [self updateWithSql:sql];
}

@end
