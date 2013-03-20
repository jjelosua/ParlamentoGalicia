CREATE TABLE `entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `numid` int(11) DEFAULT NULL,
  `season` int(11) DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  `person` tinytext,
  `body` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `numid` (`numid`)
);

CREATE TABLE `word_count` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `word` tinytext,
  `count` int(11),
  PRIMARY KEY (`id`)
);

CREATE TABLE `word_index` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `word` tinytext,
  `indice` text,
  PRIMARY KEY (`id`)
);
