use std/log

const cfgs = [
	{
		src: 'nu'
		dirs: [
			'private_Library/private_Application Support/nushell'
			dot_config/nushell
			AppData/Roaming/nushell
		]
	}
	{
		src: 'nvim'
		dirs: [
			dot_config/nvim
			AppData/Local/nvim
		]
	}
]

const srcpath = path self

def main [] {
	for cfg in $cfgs {
		genForConfig $cfg
	}
}

def genForConfig [cfg: record]: nothing -> nothing {
	log info $'Generating templates for ($cfg.src)'

	let chezroot = $srcpath | path split | drop 3 | path join
	let cheztmpldir = $srcpath | path split | drop 2 | path join .chezmoitemplates $cfg.src
	log debug $'Template dir: ($cheztmpldir)'
	# Do this annoying lambda because the glob command doesn't work on Windows.
	let sources = do { cd $cheztmpldir; ls -f **/* | where type != dir | get name }

	for ref in $cfg.dirs {
		log debug $'Ref: ($ref)'
		for $source in $sources {
			log info $"\t($source)"
			let relpath = $source | path relative-to $cheztmpldir
			let dir = ($ref | path join ($relpath | path dirname))
			log debug $'Dir: ($dir)'
			mkdir $dir
			let output = ($ref | path join $relpath) + '.tmpl'
			log debug $'Output: ($output)'
			$"{{- template \"($cfg.src)/($relpath | str replace -a '\' '/')\" . -}}\n\n" | save -f $output
			log debug $"\t($relpath)"
		}
	}
}