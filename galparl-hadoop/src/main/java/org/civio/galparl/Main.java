package org.civio.galparl;

import org.apache.commons.lang.ArrayUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.util.ToolRunner;
import org.civio.galparl.jobs.WordCountJob;
import org.civio.galparl.jobs.WordIndexJob;


/**
 * Diego Pino García <dpino@igalia.com>
 *
 */
public class Main {

	private static final String DATA_DIR = "data";	
	
	public Main() {
		
	}
	
    public static void main(String args[]) throws Exception {
    	if (ArrayUtils.contains(args, "--import")) {
    		// Import data to HBase
			Importer importer = Importer.create();
			importer.importAll(DATA_DIR);
    	} else if (ArrayUtils.contains(args, "--build-index")) {
			int res = ToolRunner.run(new Configuration(),
					new WordIndexJob(), args);
			System.exit(res);
    	} else {
    		// Run Word Count job
			int res = ToolRunner.run(new Configuration(),
					new WordCountJob(), args);
			System.exit(res);
    	}
    }

}
