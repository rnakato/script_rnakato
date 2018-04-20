import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;


public class CalcMappability {
	public static void main( String[] args ) {
		double map;
		// mappability at each nucleotide
		double ave;
		// average mappability at each position
		List<Double> window = new ArrayList<Double>();
		// window (queue)		
		Scanner in = null;
		// file handle for infile
		PrintStream out = null;  
        // file handle for outfile
		
		// arguments
		
		if ( args.length < 6 ) {
			System.out.println( "Invalid argument!" );
			System.exit(1);
		}
		String infile = args[0];
		// infile name		
		String tempfile = args[1];
		// temp file to save aveMap
		String outfile = args[2];
		// outfile name
		int taglength = Integer.parseInt( args[3] );
		// tag length
		int fraglength = Integer.parseInt( args[4] );
		// fragment length
		int binsize = Integer.parseInt( args[5] );
		// bin size
		
		// calculate mappability using window
		
		System.out.println( "Calculating mappability using window..." );
		
		try {			
			File srcFile = new File( infile );
			in = new Scanner( srcFile );
		} catch ( FileNotFoundException e ) {
			System.out.println( 
				"Couldn't open file for read" + infile );
			System.exit(1);
		} 
		try{
			File dstFile = new File( tempfile );
			out = new PrintStream( dstFile );
		}catch (FileNotFoundException e) {
			System.out.println(
				"Couldn't open file for write: " + tempfile );
			System.exit(1);
		}
		
		while ( in.hasNext() ) {
			// read nucleotide-level mappability
			
			map = Double.parseDouble( in.nextLine().trim() );
			
			// calculate mappability
			
			if ( window.size() < (fraglength-taglength) ) {
				// update window
				
				window.add( map );
				
				// do not calculate mappability ( location < 0 )
			}
			else if ( window.size() >= (fraglength-taglength) &&
					window.size() < (2*fraglength-taglength) ) {
				// update window
				
				window.add( map );
				
				// calculate mappability (simple average)
				
				ave = average( window );
				out.println( ave );
			}
			else {
				// update window
				
				window.remove(0);
				window.add( map );
				
				// calculate mappability (accurate definition)
				
				ave = mappabilityDef( window, fraglength, taglength );
				out.println( ave );
			}
		}		
		in.close();
		
	   	// export bin-level mappability

		try {			
			File srcFile = new File( tempfile );
			in = new Scanner( srcFile );
		} catch ( FileNotFoundException e ) {
			System.out.println( 
				"Couldn't open file for read" + tempfile );
			System.exit(1);
		}
		try{
			File dstFile = new File( outfile );
			out = new PrintStream( dstFile );
		}catch (FileNotFoundException e) {
			System.out.println(
				"Couldn't open file for write: " + outfile );
			System.exit(1);
		}
		
		int coord = 0;
		// coordinate
		int nCount = 0;
		// number of ave used to calculate bin-level mappability
		double aveMapSum = 0;
		// sum of subset of aveMap
		double aveMap;
		// average mappability in each bin
		
		while ( in.hasNext() ) {
			// read mappability
			
			map = Double.parseDouble( in.nextLine().trim() );
			
			// calculate bin-level mappability & write

			if ( nCount==(binsize-1) ) {
				// for each bin, calculate bin-level mappability & write
				
				aveMapSum += map;
				aveMap = aveMapSum / binsize;
				out.println( coord + "\t" + aveMap );
				
				// renew for next bin
				
				coord += binsize;
				aveMapSum = 0;
				nCount = 0;
			} else {
				// keep track of sum of ave for average calculation
				
				aveMapSum += map;	
				nCount++;
			}
		}
		out.close();
	}
	
	// calculate mappability (simple average)
	
	public static double average( List<Double> vector ) {
		double aveVal = 0;
		for ( int i=0; i<vector.size(); i++ ) {
			aveVal += vector.get(i);
		}
		return ( aveVal / vector.size() );
	}
	
	// calculate mappability (accurate definition)
	
	public static double mappabilityDef( List<Double> vector,
			int fraglength, int taglength ) {
		List<Double> windowStrand = new ArrayList<Double>();
		// window for forward/backward strand
		for ( int i=0; i<fraglength; i++) {
			windowStrand.add( vector.get( i ) );
			windowStrand.add( vector.get( fraglength-taglength+i ) );
		}
		
		double aveVal = 0;
		for ( int i=0; i<windowStrand.size(); i++ ) {
			aveVal += windowStrand.get(i);
		}
		return ( aveVal / windowStrand.size() );
	}
}
