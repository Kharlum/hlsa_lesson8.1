### Mysql Results (Server version: 8.0.27 MySQL Community Server - GPL)
|  | Dirty read | Non repeatable read | Lost update | Phantom read |
|---|---|---|---|---|
| [Read Uncommitted](README.md#read-uncommitted) | [not reproduced](README.md#dirty-read-not-reproduced-2) | [reproduced](README.md#non-repeatable-read-reproduced) | [reproduced](README.md#lost-update-reproduced-2) | [reproduced](README.md#phantom-read-reproduced) |
| [Read Committed](README.md#read-committed) | [not reproduced](README.md#dirty-read-not-reproduced-3) | [reproduced](README.md#non-repeatable-read-reproduced-1) | [reproduced](README.md#lost-update-reproduced-3) | [reproduced](README.md#phantom-read-reproduced-1) |
| [Repeatable Read](README.md#repeatable-read) | [not reproduced](README.md#dirty-read-not-reproduced) | [not reproduced](README.md#non-repeatable-read-not-reproduced) | [reproduced](README.md#lost-update-reproduced) | [not reproduced](README.md#phantom-read-not-reproduced) |
| [Serializable](README.md#serializable) | [not reproduced](README.md#dirty-read-not-reproduced-1) | [not reproduced](README.md#non-repeatable-read-not-reproduced-1) | [reproduced](README.md#lost-update-reproduced-1) | [not reproduced](README.md#phantom-read-not-reproduced-1) |

## Repeatable Read
1. **[SESSION 1]** SET autocommit = 0; SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; START TRANSACTION;  
2. **[SESSION 2]** SET autocommit = 0; SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; START TRANSACTION;  
3. **[SESSION 1]** SELECT @@SESSION.TRANSACTION_ISOLATION;  
```
+---------------------------------+
| @@SESSION.TRANSACTION_ISOLATION |
+---------------------------------+
| REPEATABLE-READ                 |
+---------------------------------+
```
4. **[SESSION 2]** SELECT @@SESSION.TRANSACTION_ISOLATION;  
```
+---------------------------------+
| @@SESSION.TRANSACTION_ISOLATION |
+---------------------------------+
| REPEATABLE-READ                 |
+---------------------------------+
```
5. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
6. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **DIRTY READ (not reproduced)**  
7. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated' WHERE id = 1;  
8. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
9. **[SESSION 1]** COMMIT;  
10. **[SESSION 2]** ROLLBACK;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **NON REPEATABLE READ (not reproduced)**  
7. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated' WHERE id = 1; <====== wait session 1 transaction ended  
8. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
9. **[SESSION 1]** COMMIT;  
10. **[SESSION 2]** ROLLBACK;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **LOST UPDATE (reproduced)**  
7. **[SESSION 1]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated v1' WHERE id = 1;  
8. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated v2' WHERE id = 1; COMMIT;  <====== table locked by session 1  
10. **[SESSION 1]** COMMIT;  
12. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+--------------------------+
| id | firstname                |
+----+--------------------------+
|  1 | Firstname 1 - Updated v2 |
+----+--------------------------+
```
13. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+--------------------------+
| id | firstname                |
+----+--------------------------+
|  1 | Firstname 1 - Updated v2 |
+----+--------------------------+
```

#### **PHANTOM READ (not reproduced)**  
7. **[SESSION 1]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
8. **[SESSION 2]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
9. **[SESSION 2]** INSERT INTO transaction_isolation.users (firstname) VALUES ('Firstname 3');  
10. **[SESSION 2]** COMMIT;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
|  3 | Firstname 3 |
+----+-------------+
```

## Serializable
1. **[SESSION 1]** SET autocommit = 0; SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; START TRANSACTION;  
2. **[SESSION 2]** SET autocommit = 0; SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; START TRANSACTION;  
3. **[SESSION 1]** SELECT @@SESSION.TRANSACTION_ISOLATION;  
```
+---------------------------------+
| @@SESSION.TRANSACTION_ISOLATION |
+---------------------------------+
| SERIALIZABLE                    |
+---------------------------------+
```
4. **[SESSION 2]** SELECT @@SESSION.TRANSACTION_ISOLATION;  
```
+---------------------------------+
| @@SESSION.TRANSACTION_ISOLATION |
+---------------------------------+
| SERIALIZABLE                    |
+---------------------------------+
```
5. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
6. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **DIRTY READ (not reproduced)**  
7. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated' WHERE id = 1; <====== wait session 1 transaction ended  
8. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
9. **[SESSION 1]** COMMIT;  
10. **[SESSION 2]** ROLLBACK;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **NON REPEATABLE READ (not reproduced)**  
7. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated' WHERE id = 1; <====== wait session 1 transaction ended  
8. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
9. **[SESSION 1]** COMMIT;  
10. **[SESSION 2]** ROLLBACK;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **LOST UPDATE (reproduced)**  
7. **[SESSION 1]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated v1' WHERE id = 1;  
8. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated v2' WHERE id = 1; COMMIT;  <====== table locked by session 1  
10. **[SESSION 1]** COMMIT;  
12. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+--------------------------+
| id | firstname                |
+----+--------------------------+
|  1 | Firstname 1 - Updated v2 |
+----+--------------------------+
```
13. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+--------------------------+
| id | firstname                |
+----+--------------------------+
|  1 | Firstname 1 - Updated v2 |
+----+--------------------------+
```

#### **PHANTOM READ (not reproduced)**  
7. **[SESSION 1]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
8. **[SESSION 2]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
9. **[SESSION 2]** INSERT INTO transaction_isolation.users (firstname) VALUES ('Firstname 3'); <====== wait session 1 transaction ended  

## READ UNCOMMITTED
1. **[SESSION 1]** SET autocommit = 0; SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; START TRANSACTION;  
2. **[SESSION 2]** SET autocommit = 0; SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; START TRANSACTION;  
3. **[SESSION 1]** SELECT @@SESSION.TRANSACTION_ISOLATION;  
```
+---------------------------------+
| @@SESSION.TRANSACTION_ISOLATION |
+---------------------------------+
| READ-UNCOMMITTED                |
+---------------------------------+
```
4. **[SESSION 2]** SELECT @@SESSION.TRANSACTION_ISOLATION;  
```
+---------------------------------+
| @@SESSION.TRANSACTION_ISOLATION |
+---------------------------------+
| READ-UNCOMMITTED                |
+---------------------------------+
```
5. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
6. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **DIRTY READ (not reproduced)**  
7. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated' WHERE id = 1;  
8. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
9. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-----------------------+
| id | firstname             |
+----+-----------------------+
|  1 | Firstname 1 - Updated |
+----+-----------------------+
```
10. **[SESSION 2]** ROLLBACK;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **NON REPEATABLE READ (reproduced)**  
7. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated' WHERE id = 1;  
8. **[SESSION 2]** COMMIT;  
9. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-----------------------+
| id | firstname             |
+----+-----------------------+
|  1 | Firstname 1 - Updated |
+----+-----------------------+
```
10. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-----------------------+
| id | firstname             |
+----+-----------------------+
|  1 | Firstname 1 - Updated |
+----+-----------------------+
```

#### **LOST UPDATE (reproduced)**  
7. **[SESSION 1]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated v1' WHERE id = 1;  
8. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated v2' WHERE id = 1; COMMIT;  <====== table locked by session 1  
10. **[SESSION 1]** COMMIT;  
12. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+--------------------------+
| id | firstname                |
+----+--------------------------+
|  1 | Firstname 1 - Updated v2 |
+----+--------------------------+
```
13. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+--------------------------+
| id | firstname                |
+----+--------------------------+
|  1 | Firstname 1 - Updated v2 |
+----+--------------------------+
```

#### **PHANTOM READ (reproduced)**  
7. **[SESSION 1]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
8. **[SESSION 2]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
9. **[SESSION 2]** INSERT INTO transaction_isolation.users (firstname) VALUES ('Firstname 3');  
10. **[SESSION 2]** COMMIT;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
|  3 | Firstname 3 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
|  3 | Firstname 3 |
+----+-------------+
```

## READ COMMITTED  
1. **[SESSION 1]** SET autocommit = 0; SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; START TRANSACTION;  
2. **[SESSION 2]** SET autocommit = 0; SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; START TRANSACTION;  
3. **[SESSION 1]** SELECT @@SESSION.TRANSACTION_ISOLATION;  
```
+---------------------------------+
| @@SESSION.TRANSACTION_ISOLATION |
+---------------------------------+
| READ-COMMITTED                  |
+---------------------------------+
```
4. **[SESSION 2]** SELECT @@SESSION.TRANSACTION_ISOLATION;  
```
+---------------------------------+
| @@SESSION.TRANSACTION_ISOLATION |
+---------------------------------+
| READ-COMMITTED                  |
+---------------------------------+
```
5. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
6. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **DIRTY READ (not reproduced)**  
7. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated' WHERE id = 1;  
8. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
9. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-----------------------+
| id | firstname             |
+----+-----------------------+
|  1 | Firstname 1 - Updated |
+----+-----------------------+
```
10. **[SESSION 2]** ROLLBACK;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
+----+-------------+
```

#### **NON REPEATABLE READ (reproduced)**  
7. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated' WHERE id = 1;  
8. **[SESSION 2]** COMMIT;  
9. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-----------------------+
| id | firstname             |
+----+-----------------------+
|  1 | Firstname 1 - Updated |
+----+-----------------------+
```
10. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+-----------------------+
| id | firstname             |
+----+-----------------------+
|  1 | Firstname 1 - Updated |
+----+-----------------------+
```

#### **LOST UPDATE (reproduced)**  
7. **[SESSION 1]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated v1' WHERE id = 1;  
8. **[SESSION 2]** UPDATE transaction_isolation.users SET firstname = 'Firstname 1 - Updated v2' WHERE id = 1; COMMIT;  <====== table locked by session 1  
10. **[SESSION 1]** COMMIT;  
12. **[SESSION 1]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+--------------------------+
| id | firstname                |
+----+--------------------------+
|  1 | Firstname 1 - Updated v2 |
+----+--------------------------+
```
13. **[SESSION 2]** SELECT * FROM transaction_isolation.users WHERE id = 1;  
```
+----+--------------------------+
| id | firstname                |
+----+--------------------------+
|  1 | Firstname 1 - Updated v2 |
+----+--------------------------+
```

#### **PHANTOM READ (reproduced)**  
7. **[SESSION 1]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
8. **[SESSION 2]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
+----+-------------+
```
9. **[SESSION 2]** INSERT INTO transaction_isolation.users (firstname) VALUES ('Firstname 3');  
10. **[SESSION 2]** COMMIT;  
11. **[SESSION 1]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
|  3 | Firstname 3 |
+----+-------------+
```
12. **[SESSION 2]** SELECT * FROM transaction_isolation.users;  
```
+----+-------------+
| id | firstname   |
+----+-------------+
|  1 | Firstname 1 |
|  2 | Firstname 2 |
|  3 | Firstname 3 |
+----+-------------+
```
