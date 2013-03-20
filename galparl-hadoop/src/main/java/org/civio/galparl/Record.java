package org.civio.galparl;

import static org.apache.commons.lang.StringUtils.trim;

import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

import org.apache.commons.lang.StringUtils;

/**
 * 
 * @author Diego Pino García <dpino@igalia.com>
 *
 */
public class Record {

	private static int seqNumber = 0;
	
	public static final String SEASON = "season";
	public static final String NUM_ID = "numid";
	public static final String DATE = "date";
	public static final String PERSON = "person";
	public static final String BODY = "body";
	
	private String id;
	private int numid;
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
		this.numid = nextId();
		this.date = date;
		this.person = person;
		this.body = body;
	}

	private int nextId() {
		return ++seqNumber;
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

	public int getNumId() {
		return numid;
	}

	@Override
	public String toString() {
		return "Record [season=" + season + ", date=" + date + ", person="
				+ person + ", body=" + body + "]";
	}

}