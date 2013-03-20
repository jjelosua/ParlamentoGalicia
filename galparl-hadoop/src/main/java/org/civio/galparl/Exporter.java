package org.civio.galparl;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.MasterNotRunningException;
import org.apache.hadoop.hbase.ZooKeeperConnectionException;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.util.Bytes;
import org.civio.galparl.utils.HBaseHelper;

public class Exporter {

	private HBaseHelper hbase;
	
	private Exporter() {
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
	
	public static Exporter create() {
		return new Exporter();
	}
	
	public void exportTable(String tableName, List<Attribute> attributes) {
		try {
			HTable table = new HTable(tableName);		
			ResultScanner scanner = hbase.scan(table, 100);
			for (Result each: scanner) {
				System.out.println(toSQL(tableName, getValues(attributes, each)));
			}			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private String toSQL(String tableName, List<Value> values) {		
		List<String> fieldNames = new ArrayList<String>();
		List<String> fieldValues = new ArrayList<String>();
		for (Value each: values) {
			fieldNames.add(each.getName());
			fieldValues.add(each.getValue());
		}
		return String.format("INSERT INTO %s(%s) VALUES(%s);", "entries",
				StringUtils.join(fieldNames, ","),
				StringUtils.join(fieldValues, ","));
	}

	private List<Value> getValues(List<Attribute> attributes,
			Result each) {
		List<Value> result = new ArrayList<Value>();
		for (Attribute attr: attributes) {
			result.add(new Value(attr, each));
		}
		return result;
	}
		
}

class Attribute {
	
	private String type;
	private String name;
	
	Attribute(String type, String name) {
		this.type = type;
		this.name = name;
	}
	
	public String type() {
		return type;
	}

	public String name() {
		return name;
	}

}

class Value {
	
	private String type;
	private String name;
	private KeyValue keyValue;
	
	Value(Attribute attr, Result row) {
		this.type = attr.type();
		this.name = attr.name();
		this.keyValue = row.getColumnLatest(Bytes.toBytes(attr.name()),
				Bytes.toBytes(""));
	}

	public String getType() {
		return type;
	}

	public String getName() {
		return name;
	}		

	public String getValue() {
		if (type.equals("integer")) {
			return String.valueOf(valueAsInt());
		}
		if (type.equals("long")) {
			return String.valueOf(valueAsLong());
		}
		return String.format("'%s'", escape(valueAsString()));
	}
	
	private String escape(String str) {
		return str.replace("'", "''");
	}

	public Integer valueAsInt() {
		return Bytes.toInt(keyValue.getValue());
	}

	public Long valueAsLong() {
		return Bytes.toLong(keyValue.getValue());
	}
	
	public String valueAsString() {
		return Bytes.toString(keyValue.getValue());
	}

}