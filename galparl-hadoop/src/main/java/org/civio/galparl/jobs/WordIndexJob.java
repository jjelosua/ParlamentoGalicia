package org.civio.galparl.jobs;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import org.apache.commons.lang.StringUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.hbase.mapreduce.TableMapper;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.civio.galparl.Record;
import org.civio.galparl.utils.JobCommon;
import org.civio.galparl.utils.JobRunner;


/**
 * Diego Pino García <dpino@igalia.com>
 * 
 * Creates an index of words
 * 
 * 	<word> <list-of-row-ids>
 * 
 */
public class WordIndexJob extends Configured implements Tool {

	private static final String NAME = "WordIndexJob";
	private static final String DIR_OUT = "output/wordindex";
	
	public static class MapClass extends
			TableMapper<Text, Text> {

		private Text word = new Text();
		
		@Override
		protected void map(ImmutableBytesWritable key, Result row,
				Context context) throws IOException, InterruptedException {
            
			String body = Bytes
					.toString(JobCommon.getColumnFamily(row, Record.BODY));
			int numId = Bytes.toInt(JobCommon.getColumnFamily(row,
					Record.NUM_ID));
			Integer season = Bytes.toInt(JobCommon.getColumnFamily(row,
					Record.SEASON));
			
			StringTokenizer tokenizer = new StringTokenizer(body);
			while (tokenizer.hasMoreTokens()) {
				String token = JobCommon.removeSpecialChars(tokenizer
						.nextToken());
				word.set(JobCommon.toKey(season, token));
				context.write(word, new Text(String.valueOf(numId)));
			}

		}

	}
	
	public static class Reduce extends
			Reducer<Text, Text, Text, Text> {

		@Override
		protected void reduce(Text word, Iterable<Text> values,
				Context context) throws IOException, InterruptedException {

			List<String> ids = new ArrayList<String>();			
			for (Text each : values) {
				ids.add(each.toString());
			}
			context.write(word, new Text(StringUtils.join(ids, ",")));
		}
	}
	
    private static Job setupJob() throws IOException {
        Configuration config = HBaseConfiguration.create();
        Job job = new Job(config, WordIndexJob.NAME);
        job.setJarByClass(WordIndexJob.class);

        Scan scan = new Scan();
        scan.setCaching(500);
        scan.setCacheBlocks(false); // don't set to true for MR jobs

        // Mapper
        TableMapReduceUtil.initTableMapperJob(
                "parlament-entries", // input HBase table name
                scan, // Scan instance to control CF and attribute selection
                WordIndexJob.MapClass.class,
                Text.class, Text.class,
                job);

        job.setCombinerClass(WordIndexJob.Reduce.class);
        job.setReducerClass(WordIndexJob.Reduce.class);

        FileOutputFormat.setOutputPath(job, new Path(WordIndexJob.DIR_OUT));

        return job;
    }

	@Override
	public int run(String[] arg0) throws Exception {
		if (JobRunner.run(setupJob())) {
            System.out.println("Job completed!");
        }
		return 0;
	}
	
}
