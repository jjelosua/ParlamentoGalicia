package org.civio.galparl;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.util.ToolRunner;
import org.civio.galparl.jobs.CongressAnalysisJob;

/**
 * Diego Pino García <dpino@igalia.com>
 *
 */
class Main {

    public static void main(String args[]) throws Exception {
        int res = ToolRunner.run(new Configuration(), new CongressAnalysisJob(), args);
        System.exit(res);
    }

}
