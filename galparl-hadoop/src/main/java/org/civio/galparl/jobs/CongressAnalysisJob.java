package org.civio.galparl.jobs;

import java.io.IOException;
import java.util.StringTokenizer;

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
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.civio.galparl.utils.JobRunner;


/**
 * Diego Pino García <dpino@igalia.com>
 *
 */
public class CongressAnalysisJob extends Configured implements Tool {

	private static final String NAME = "CongressAnalysisJob";
	private static final String DIR_OUT = "output/";
	
	public static class MapClass extends
			TableMapper<Text, IntWritable> {

		private static final IntWritable ONE = new IntWritable(1);
		private Text word = new Text();
		
		@Override
		protected void map(ImmutableBytesWritable key, Result row,
				Context context) throws IOException, InterruptedException {
            
            byte[] value = getColumnFamily(row, "body");       
            if (value == null) {
                return;
            }

            String delim = " .:";
			StringTokenizer tokenizer = new StringTokenizer(Bytes.toString(value));
			while (tokenizer.hasMoreTokens()) {
				String token = removeSpecialChars(tokenizer.nextToken());
				word.set(token);
				context.write(word, ONE);
			}

		}
		
		private String removeSpecialChars(String input) {
			input = input.toLowerCase();
			input = input.replaceAll("[^a-záéíóú]$", "").replaceAll("^[^a-záéíóú]", "");
			input = input.replaceAll("[\\\"\\”\\-\\)\\!\\?]$|\\.{1,3}", "");
			return input.replaceAll("^[\\\"\\”\\-\\)\\!\\?]", "");
		}

		private byte[] getColumnFamily(Result row, String prefix) {
			return getColumnFamily(row, prefix, "");
		}
		
		private byte[] getColumnFamily(Result row, String prefix, String qualifier) {
            return row.getValue(Bytes.toBytes(prefix), Bytes.toBytes(qualifier));			
		}
		
	}
	
	public static class Reduce extends
			Reducer<Text, IntWritable, Text, IntWritable> {

		private IntWritable count = new IntWritable();

		@Override
		protected void reduce(Text key, Iterable<IntWritable> values,
				Context context) throws IOException, InterruptedException {

			int sum = 0;
			for (IntWritable value : values) {
				sum += value.get();
			}
			count.set(sum);
			context.write(key, count);
		}
	}
	
    private static Job setupJob() throws IOException {
        Configuration config = HBaseConfiguration.create();
        Job job = new Job(config, CongressAnalysisJob.NAME);
        job.setJarByClass(CongressAnalysisJob.class);

        Scan scan = new Scan();
        scan.setCaching(500);
        scan.setCacheBlocks(false); // don't set to true for MR jobs

        // Mapper
        TableMapReduceUtil.initTableMapperJob(
                "parlament-entries", // input HBase table name
                scan, // Scan instance to control CF and attribute selection
                CongressAnalysisJob.MapClass.class,
                Text.class, IntWritable.class,
                job);

        job.setCombinerClass(CongressAnalysisJob.Reduce.class);
        job.setReducerClass(CongressAnalysisJob.Reduce.class);

        FileOutputFormat.setOutputPath(job, new Path(CongressAnalysisJob.DIR_OUT));

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