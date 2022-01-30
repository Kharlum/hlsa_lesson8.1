USE transaction_isolation;

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int unsigned not null auto_increment,
  `firstname` varchar(255) not null,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT = 1 CHARACTER SET utf8;

INSERT INTO `users` (firstname) VALUES ('Firstname 1'), ('Firstname 2');

