package org.civio.galparl.jobs;

import static org.apache.hadoop.hbase.util.Bytes.toBytes;

import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.hbase.mapreduce.TableMapper;
import org.apache.hadoop.hbase.mapreduce.TableReducer;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.util.Tool;
import org.civio.galparl.utils.HBaseHelper;
import org.civio.galparl.utils.JobCommon;
import org.civio.galparl.utils.JobRunner;


/**
 * Diego Pino García <dpino@igalia.com>
 *
 * Counts number of words
 */	
public class WordCountHBaseJob extends Configured implements Tool {

	private static final String NAME = "WordCountHBaseJob";
	private static final String INPUT_TABLE = "parlament-entries";
	private static final String OUTPUT_TABLE = "parlament-words";
	
	public static class MapClass extends
			TableMapper<Text, IntWritable> {

		private static final IntWritable ONE = new IntWritable(1);
		private Text word = new Text();
		
		@Override
		protected void map(ImmutableBytesWritable key, Result row,
				Context context) throws IOException, InterruptedException {
            
			String body = Bytes
					.toString(JobCommon.getColumnFamily(row, "body"));

			StringTokenizer tokenizer = new StringTokenizer(body);
			while (tokenizer.hasMoreTokens()) {
				String token = JobCommon.removeSpecialChars(tokenizer
						.nextToken());
				word.set(token);
				context.write(word, ONE);
			}

		}
				
	}
	
	public static class Reduce extends
			TableReducer<Text, IntWritable, ImmutableBytesWritable> {

		public void reduce(Text key, Iterable<IntWritable> values,
				Context context) throws IOException, InterruptedException {
			int sum = 0;
			for (IntWritable value : values) {
				sum += value.get();
			}
			Put put = new Put(toBytes(key.toString()));
			put.add(toBytes("count"), toBytes(""), toBytes(sum));
			context.write(null, put);
		}			
	}
	
    private static Job setupJob() throws IOException {
        Configuration config = HBaseConfiguration.create();
        Job job = new Job(config, WordCountHBaseJob.NAME);
        job.setJarByClass(WordCountHBaseJob.class);        
        
        HBaseHelper hbase = HBaseHelper.create();
        hbase.createTable(OUTPUT_TABLE, "count");
        
        Scan scan = new Scan();
        scan.setCaching(500);
        scan.setCacheBlocks(false); // don't set to true for MR jobs

        // Mapper
        TableMapReduceUtil.initTableMapperJob(
                INPUT_TABLE,
                scan,
                WordCountHBaseJob.MapClass.class,
                Text.class, IntWritable.class,
                job);        
        TableMapReduceUtil.initTableReducerJob(
        		OUTPUT_TABLE,
        		WordCountHBaseJob.Reduce.class,
        		job);
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
