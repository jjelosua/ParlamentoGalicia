CREATE TABLE `entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `numid` int(11) DEFAULT NULL,
  `season` int(11) DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  `person` tinytext,
  `honors` tinytext,
  `fullname` tinytext,
  `party` varchar(32),
  `sex` varchar(1),
  `body` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `numid` (`numid`)
);

CREATE TABLE `word_count` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `season` int(11),
  `word` tinytext,
  `count` int(11),
  PRIMARY KEY (`id`)
);

CREATE TABLE `word_index` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `season` int(11),
  `word` tinytext,
  `indice` text,
  PRIMARY KEY (`id`)
);

CREATE TABLE `deputies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fullname` tinytext,
  `name` tinytext,
  `surname` tinytext,
  `season` int(11),
  `party` tinytext,
  `sex` tinytext,
  PRIMARY KEY (`id`)
);
