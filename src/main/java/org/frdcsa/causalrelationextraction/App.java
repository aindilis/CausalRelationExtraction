package org.frdcsa.causalrelationextraction;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringReader;
import java.util.HashMap;
import java.util.List;
import java.util.Scanner;

import yxf.RelationExtractor;
import yxf.Cue;
import edu.stanford.nlp.ling.CoreLabel;
import edu.stanford.nlp.process.TokenizerFactory;
import edu.stanford.nlp.parser.lexparser.LexicalizedParser;
import edu.stanford.nlp.process.CoreLabelTokenFactory;
import edu.stanford.nlp.process.PTBTokenizer;
import edu.stanford.nlp.trees.Tree;

public class App 
{
    /**
     * @param args
     * @throws IOException 
     */
    public static void main(String[] args) throws IOException {
	// TODO Auto-generated method stub
	// String sent = "The Murray Hill, N.J., company said full-year earnings may be off 33 cents a share because the company removed a catheter from the market.";

	//load parser model
	LexicalizedParser lp = LexicalizedParser
	    .loadModel("edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz");
		
		
	// parser sentence
		
	Tree parse= null;
	TokenizerFactory<CoreLabel> tokenizerFactory = PTBTokenizer.factory
	    (new CoreLabelTokenFactory(), "");
		
	RelationExtractor re = new RelationExtractor();
	BufferedWriter w = new BufferedWriter
	    (new FileWriter("data/relations.txt"));

	File f = new File(args[0]);
	Scanner sc = new Scanner(f);

	while(sc.hasNextLine()){
	    String sent = sc.nextLine();

	    List<CoreLabel> rawword = tokenizerFactory.getTokenizer
		(new StringReader(sent)).tokenize();
		
	    parse = lp.apply(rawword);
		
	    HashMap<Integer, Cue> relations = re.getCandidate(sent, lp,parse);
		
	    for(Cue c : relations.values()){
		c.print(w);
	    }

	    w.write("-\n");
	}

	w.close();
	System.out.println("Finish!");
    }

}
