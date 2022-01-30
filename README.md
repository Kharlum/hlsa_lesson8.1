## READ COMMITTED  
**DIRTY READ**  
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
