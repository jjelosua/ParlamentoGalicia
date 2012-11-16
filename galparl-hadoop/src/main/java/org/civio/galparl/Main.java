package org.civio.galparl;

import org.apache.commons.lang.ArrayUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.util.ToolRunner;
import org.civio.galparl.jobs.CongressAnalysisJob;


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
    	} else {
    		// Run Hadoop job
			int res = ToolRunner.run(new Configuration(),
					new CongressAnalysisJob(), args);
			System.exit(res);
    	}
    }

}
