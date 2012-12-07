package org.civio.galparl;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.civio.galparl.jobs.WordCountHBaseJob;
import org.civio.galparl.jobs.WordCountJob;
import org.civio.galparl.jobs.WordIndexJob;


/**
 * Diego Pino García <dpino@igalia.com>
 *
 */
public class Main {

	private static final String DATA_DIR = "data";
	private static final String DEFAULT_JOB = "--word-count-hbase";

	private static final Map<String, JobCommand> jobCommands = new HashMap<String, JobCommand>() {
		{
			put("--build-index",
					JobCommand.create(new WordIndexJob()));
			put("--word-count",
					JobCommand.create(new WordCountJob()));
			put("--word-count-hbase",
					JobCommand.create(new WordCountHBaseJob()));
		}
	};

	public Main() {

	}

    public static void main(String args[]) throws Exception {
    	if (args.length > 1) {
    		return;
    	}
    	String arg = args.length == 1 ? args[0] : DEFAULT_JOB;

    	// Import data to HBase
    	if (arg.equals("--import")) {
			Importer importer = Importer.create();
			importer.importAll(DATA_DIR);
			return;
    	}
    	// Execute job
    	JobCommand command = jobCommands.get(arg);
    	if (command != null) {
    		System.exit(command.execute());
    	}
    }

}

class JobCommand {

	private Tool tool;

	public static JobCommand create(Tool tool) {
		return new JobCommand(tool);
	}

	private JobCommand() {

	}

	public JobCommand(Tool tool) {
		this.tool = tool;
	}

	public int execute() {
		try {
			return ToolRunner.run(new Configuration(), tool,
					ArrayUtils.EMPTY_STRING_ARRAY);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return -1;
	}
}
