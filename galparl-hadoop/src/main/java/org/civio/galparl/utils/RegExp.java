package org.civio.galparl.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RegExp {

    private Pattern pattern;

    private RegExp(String regexp) {
        this.pattern = Pattern.compile(regexp);
    }

    public static RegExp create(String regexp) {
        return new RegExp(regexp);
    }

    public List<String> evaluate(String line) {
        List<String> result = new ArrayList<String>();

        int count = 1;
        Matcher matcher = pattern.matcher(line);
        while (matcher.find()) {
            result.add(matcher.group(count++));
        }
        return result;
    }
	
}