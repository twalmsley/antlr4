/*
 * Copyright (c) 2012-2019 The ANTLR Project. All rights reserved.
 * Use of this file is governed by the BSD 3-clause license that
 * can be found in the LICENSE.txt file in the project root.
 */
package org.antlr.v4.codegen.target;

import org.antlr.v4.Tool;
import org.antlr.v4.codegen.CodeGenerator;
import org.antlr.v4.codegen.Target;
import org.antlr.v4.codegen.UnicodeEscapes;
import org.antlr.v4.tool.ast.GrammarAST;
import org.stringtemplate.v4.STGroup;
import org.stringtemplate.v4.StringRenderer;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

/**
 * @author Tony Walmsley on behalf of Num Technologies Ltd, UK.
 */
public class RubyTarget extends Target {
	/**
	 * The Ruby target can cache the code generation templates.
	 */
	private static final ThreadLocal<STGroup> targetTemplates = new ThreadLocal<STGroup>();

	protected static final String[] rubyKeywords = {
		"__ENCODING__",
		"__LINE__",
		"__FILE__",
		"BEGIN",
		"END",
		"alias",
		"and",
		"begin",
		"break",
		"case",
		"class",
		"def",
		"defined?",
		"do",
		"else",
		"elsif",
		"end",
		"ensure",
		"false",
		"for",
		"if",
		"in",
		"module",
		"next",
		"nil",
		"not",
		"or",
		"redo",
		"rescue",
		"retry",
		"return",
		"self",
		"super",
		"then",
		"true",
		"undef",
		"unless",
		"until",
		"when",
		"while",
		"yield"
	};

	/**
	 * Avoid grammar symbols in this set to prevent conflicts in gen'd code.
	 */
	protected final Set<String> badWords = new HashSet<String>();

	public RubyTarget(CodeGenerator gen) {
		super(gen, "Ruby");
	}

	@Override
	public String getVersion() {
		return Tool.VERSION; // Ruby and tool versions move in lock step
	}

	public Set<String> getBadWords() {
		if (badWords.isEmpty()) {
			addBadWords();
		}

		return badWords;
	}

	protected void addBadWords() {
		badWords.addAll(Arrays.asList(rubyKeywords));
		badWords.add("rule");
		badWords.add("parserRule");
	}

	@Override
	public int getSerializedATNSegmentLimit() {
		// 65535 is the class file format byte limit for a UTF-8 encoded string literal
		// 3 is the maximum number of bytes it takes to encode a value in the range 0-0xFFFF
		return 65535 / 3;
	}

	@Override
	protected boolean visibleGrammarSymbolCausesIssueInGeneratedCode(GrammarAST idNode) {
		return getBadWords().contains(idNode.getText());
	}

	@Override
	protected STGroup loadTemplates() {
		STGroup result = targetTemplates.get();
		if (result == null) {
			result = super.loadTemplates();
			result.registerRenderer(String.class, new RubyTarget.RubyStringRenderer(), true);
			targetTemplates.set(result);
		}

		return result;
	}

	protected static class RubyStringRenderer extends StringRenderer {

		@Override
		public String toString(Object o, String formatString, Locale locale) {
			if ("java-escape".equals(formatString)) {
				// 5C is the hex code for the \ itself
				return ((String) o).replace("\\u", "\\u005Cu");
			}

			return super.toString(o, formatString, locale);
		}

	}

	@Override
	protected void appendUnicodeEscapedCodePoint(int codePoint, StringBuilder sb) {
		UnicodeEscapes.appendJavaStyleEscapedCodePoint(codePoint, sb);
	}

}
