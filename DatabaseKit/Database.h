//
//  Database.h
//  FitMe
//
//  Created by PC-wzj on 17/2/9.
//  Copyright © 2017年 方得. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDatabase.h>

@class Database;

typedef void(^ResultSet)(FMResultSet *set);

@protocol DatabaseDelegate <NSObject>

@optional
- (BOOL)selectDatabaseDelegate:(FMResultSet *) set;

@end

/**
 数据库操作类
 */
@interface Database : NSObject

@property (nonatomic, weak) id<DatabaseDelegate> delegate;

/**
 数据库名称
 */
@property (nonatomic, copy) NSString *DBName;

/**
 实例化方法

 @return 数据库操作方法对象
 */
- (instancetype)init;

/**
 插入数据操作方法

 @param sql SQL语句
 */
- (BOOL) insertDataWithSql:(NSString *) sql;

/**
 插入数据操作

 @param table 表名
 @param keys 字段名 -> 数组
 @param values 对应字段的值 -> 数组
 @return 返回YES操作成功 NO插入失败
 */
- (BOOL) insertDataToTable:(NSString *)table withKeys:(NSArray *)keys andValues:(NSArray *)values;


/**
 更新数据库方法

 @param sql 更新数据库 SQL语句
 @return 操作结果YES操作成功  NO操作失败
 */
- (BOOL) updateWithSql:(NSString *)sql;

/**
 更新数据库方法

 @param table 更新目标表
 @param keyValue 对应键值
 @param condition 更新条件
 @return 更新结果YES->更新成功 NO->更新失败
 */
- (BOOL) updateWithTable:(NSString *)table setKeyValue:(NSDictionary *)keyValue whereCondition:(NSString *)condition;


/**
 更新数据库方法

 @param table 更新数据目标表
 @param keys 更新字段
 @param values 对应字段值
 @param condition 更新条件 为NULL时更新整个表
 @return 更新操作结果YES更新成功反之失败
 */
- (BOOL) updateWithTable:(NSString *)table keys:(NSArray *)keys setValues:(NSArray *)values whereCondition:(NSString *)condition;

/**
 查询操作

 @param sql 查询语句
 @return 结果集合
 */
- (FMResultSet *) selectDataWithSql:(NSString *) sql;

/**
 数据库查询操作

 @param sql 查询语句
 @param set 结果集block
 */
- (void) selectDataWithSql:(NSString *)sql resultSet:(ResultSet)set;

/**
 根据sql语句删除数据
 
 @param sql 删除数据的sql语句
 @return 返回数据库操作结果YES操作成功，NO操作失败
 */
- (BOOL) deleteDataWithSql:(NSString *) sql;

/**
 数据库删除数据操作方法（condition = null 时删除表中所有数据）
 
 @param table 删除数据的目标表
 @param condition 删除条件
 @return 数据库操作结果YES操作成功，NO操作失败
 */
- (BOOL) deleteDataWithTable:(NSString *)table where:(NSString *)condition;

@end
