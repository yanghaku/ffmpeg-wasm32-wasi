fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() <= 2 {
        eprintln!("Usage: {} <input file> <output file>\n", args[0]);
        std::process::exit(0);
    }

    let filename = args.get(1).unwrap();
    let out_filename = args.get(2).unwrap();

    eprintln!("{} {}", filename, out_filename);
    todo!();
}
