package org.civio.galparl;

import static org.apache.commons.lang.StringUtils.trim;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.TrueFileFilter;
import org.apache.commons.lang.StringUtils;
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
			HTable table = hbase.getOrCreateTable(TABLE_NAME, Record.SEASON, Record.DATE, Record.PERSON, Record.BODY);

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
				hbase.insert(table, record.getId(), Record.SEASON, "", record.getSeason());
	            hbase.insert(table, record.getId(), Arrays.asList(Record.PERSON, "", record.getPerson()));
	            hbase.insert(table, record.getId(), Record.DATE, "", record.getTimestamp());
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
	
	/**
	 * 
	 * @author Diego Pino García <dpino@igalia.com>
	 *
	 */
	static class Record {

		private static final String SEASON = "season";
		private static final String DATE = "date";
		private static final String PERSON = "person";
		private static final String BODY = "body";
		
		private String id;
		private int season;
		private Date date;
		private String person;
		private String body;

		private static final Map<String, Integer> months =  new TreeMap<String, Integer>() {{
			put("xaneiro",   Integer.valueOf(1));
			put("febreiro",  Integer.valueOf(2));
			put("marzo",     Integer.valueOf(3));
			put("abril",     Integer.valueOf(4));
			put("maio",      Integer.valueOf(5));
			put("xuño",      Integer.valueOf(6));
			put("xullo",     Integer.valueOf(7));
			put("agosto",    Integer.valueOf(8));
			put("setembro",  Integer.valueOf(9));
			put("outubro",   Integer.valueOf(10));
			put("novembro",  Integer.valueOf(11));
			put("decembro",  Integer.valueOf(12));
		}};
		
		private Record() {
			
		}
		
		public static Record create(List<String> content) {
			String firstLine = content.get(0);
			firstLine = firstLine.substring(1, firstLine.length() - 1);
			
			String[] parts = firstLine.split(";");
			Integer season = Integer.valueOf(trim(parts[0]));
			Date date = parseDate(trim(parts[1]));
			String person = trim(parts[2]);
			
			content.remove(0);
			String body = trim(StringUtils.join(content, "\n"));
			
			return new Record(season, date, person, body);
		}
		
		public Record(Integer season, Date date, String person, String body) {
			id = UUID.randomUUID().toString();
			this.season = season;
			this.date = date;
			this.person = person;
			this.body = body;
		}

		private static Date parseDate(String date) {
			String[] parts = date.split(" de ");
			
			int day = Integer.valueOf(trim(parts[0]));
			int month = months.get(trim(parts[1]));
			int year = Integer.valueOf(trim(parts[2]));
			
			Calendar calendar = Calendar.getInstance();
			calendar.set(year, month, day);
			return calendar.getTime();
		}

		public String getId() {
			return id;
		}
		
		public int getSeason() {
			return season;
		}

		public Date getDate() {
			return date;
		}
		
		public Long getTimestamp() {
			return Long.valueOf(date.getTime());
		}

		public String getPerson() {
			return person;
		}

		public String getBody() {
			return body;
		}
		
		@Override
		public String toString() {
			return "Record [season=" + season + ", date=" + date + ", person="
					+ person + ", body=" + body + "]";
		}

	}
		
}