Compile
-------

$ mvn clean install

Run
---

First, import files in data/ into HBase

$ mvn exec:java -Dexec.mainClass=org.civio.galparl.Main -Dexec.args="--import"

As a result, the table parlament-entries is created and all the data is loaded into it.

Now run any of the 3 available jobs:

   * build-index. Creates an index of in which entries appears a certain word. Filesystem output.
   * word-count. Counts all words. Filesystem output.
   * word-count-hbase. Counts all the words. Output is stored in table __ in HBase.

For instace, to run _word-count_:

$ mvn exec:java -Dexec.mainClass=org.civio.galparl.Main -Dexec.args="--word-count"
