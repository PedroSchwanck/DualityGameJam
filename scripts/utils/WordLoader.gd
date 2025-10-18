extends Node
class_name WordLoader

const PATHS := {
    "pt_br": "res://assets/wordlists/pt_br.txt",
    "en_us": "res://assets/wordlists/en_us.txt"
}

func load_words(lang: String) -> PackedStringArray:
    var path := PATHS.get(lang, PATHS.pt_br)
    if not ResourceLoader.exists(path):
        push_warning("Word list not found: %s" % path)
        return PackedStringArray()
    var f := FileAccess.open(path, FileAccess.READ)
    var words: PackedStringArray = []
    while not f.eof_reached():
        var line := f.get_line().strip_edges()
        if line != "":
            words.push_back(line)
    f.close()
    return words

func build_text(lang: String, count: int, seed: int = 0) -> String:
    var rng := RandomNumberGenerator.new()
    if seed != 0:
        rng.seed = seed
    else:
        rng.randomize()
    var w := load_words(lang)
    if w.size() == 0:
        return "sem palavras carregadas"
    var chosen: Array[String] = []
    for i in count:
        chosen.append(w[rng.randi_range(0, w.size() - 1)])
    return " ".join(chosen)
