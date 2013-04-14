package org.civio.galparl;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.TrueFileFilter;
import org.apache.hadoop.hbase.MasterNotRunningException;
import org.apache.hadoop.hbase.ZooKeeperConnectionException;
import org.apache.hadoop.hbase.client.HTable;
import org.civio.galparl.utils.HBaseHelper;


/**
 * 
 * Parses data from files and imports then into HBase
 * 
 * @author Diego Pino García <dpino@igalia.com>
 *
 */
public class Importer {

	private static final String TABLE_NAME = "parlament-entries";

	private HBaseHelper hbase;
	private int imported = 0, failed = 0;
	
	private Importer() {
		try {
			hbase = HBaseHelper.create();
		} catch (MasterNotRunningException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ZooKeeperConnectionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static Importer create() {
		return new Importer();
	}
		
	public void importAll(String dir) {
		try {
			HTable table = hbase.getOrCreateTable(TABLE_NAME, Record.NUM_ID, Record.SEASON, Record.DATE, 
					Record.PERSON, Record.FULLNAME, Record.HONORS, Record.BODY);

			Collection<File> files = FileUtils.listFiles(new File(dir),
					TrueFileFilter.TRUE, TrueFileFilter.TRUE);
			
			List<Record> records = new ArrayList<Record>();
            for (File each: files) {
                String filename = each.getCanonicalPath();
                records.addAll(importFile(filename));
            }
            
            for (Record each: records) {
            	insertRecord(table, each);
            }
            
            printSummary();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
		
	private void printSummary() {
		System.out.println(String.format(
				"Table: %s (total: %d; imported: %d; failed: %d)", TABLE_NAME,
				imported + failed, imported, failed));
	}
	
	private void insertRecord(HTable table, Record record) {    	
        String body = record.getBody();
        if (body != null && !body.isEmpty()) {
            try {
	            hbase.insert(table, record.getId(), Record.NUM_ID, "", record.getNumId());
				hbase.insert(table, record.getId(), Record.SEASON, "", record.getSeason());
	            hbase.insert(table, record.getId(), Arrays.asList(Record.PERSON, "", record.getPerson()));
	            hbase.insert(table, record.getId(), Arrays.asList(Record.FULLNAME, "", record.getFullName()));
	            hbase.insert(table, record.getId(), Arrays.asList(Record.HONORS, "", record.getHonors()));
	            hbase.insert(table, record.getId(), Record.DATE, "", record.getTimestamp());
	            hbase.insert(table, record.getId(), Arrays.asList(Record.BODY, "", body));	            
	            hbase.insert(table, record.getId(), Arrays.asList(Record.BODY, "", body));	            
	            imported++;
			} catch (IOException e) {
				e.printStackTrace();
			}
        } else {
            failed++;
        }
	}
	
	public static List<Record> importFile(String filename) {
		List<Record> result = new ArrayList<Record>();
		Record record;
		RecordFactory recordFactory;
		try {
			recordFactory = RecordFactory.create(filename);
			while ((record = recordFactory.getRecord()) != null) {
				result.add(record);
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();			
		}
		return result;
	}

	/**
	 * 
	 * @author Diego Pino García <dpino@igalia.com>
	 *
	 */
	static class RecordFactory {

		private BufferedReader filereader;
		
		private DataInputStream in;
		
		private int max = -1;
		
		private int pos = 0;
		
		private RecordFactory() {
			
		}
		
		public static RecordFactory create(String filename, int max) throws FileNotFoundException {
			RecordFactory result = RecordFactory.create(filename);
			result.max = max;
			return result;
		}
		
		public static RecordFactory create(String filename)
				throws FileNotFoundException {
			RecordFactory result = new RecordFactory();
			result.openFile(filename);
			return result;
		}
		
		private void openFile(String filename)
				throws FileNotFoundException {
			if (filereader == null) {
				FileInputStream fstream = new FileInputStream(filename);
				in = new DataInputStream(fstream);
				filereader = new BufferedReader(new InputStreamReader(in));
			}
		}
		
		private void closeFile() throws IOException {
			in.close();
		}
						
		public Record getRecord() throws IOException {
			List<String> content = new ArrayList<String>();
			String line = readLine();
			if (line == null) {
				closeFile();
				return null;
			}
			content.add(line);
			do {
				if (pos == max) {
					closeFile();
					return null;
				}
				
				filereader.mark(256);
				line = readLine();
				if (line == null) {
					pos++;
					return Record.create(content);
				}
				if (line.startsWith("[") && line.endsWith("]")) {
					pos++;
					filereader.reset();
					return Record.create(content);
				}
				content.add(line);
			} while (true);	
		}
		
		private String readLine() {
			try {
				return filereader != null ? filereader.readLine() : new String();
			} catch (IOException e) {
				e.printStackTrace();
				return null;
			}			
		}
		
	}
		
}