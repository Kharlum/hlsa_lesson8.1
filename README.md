### Mysql Results
|  | Dirty read | Lost update | Non repeatable read | Phantom read |
|---|---|---|---|---|
| **Read Uncommitted**  | not reproduced | reproduced | reproduced | reproduced |
| **Read Committed**    | not reproduced | reproduced | reproduced | reproduced |
| **Repeatable Read**   | - | - | - | - |
| **Serializable**      | - | - | - | - |

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
