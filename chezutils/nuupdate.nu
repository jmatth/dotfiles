const nurefs = [
	'private_Library/private_Application Support/nushell'
	'dot_config/nushell'
]

const srcpath = path self

def main [] {
	let chezroot = $srcpath | path split | drop 3 | path join
	let cheztmpldir = $srcpath | path split | drop 2 | path join .chezmoitemplates nu
	let sources = glob --no-dir --no-symlink ($cheztmpldir | path join ** *)
	for ref in $nurefs {
		print $ref
		for $source in $sources {
			let relpath = $source | path relative-to $cheztmpldir
			mkdir ($ref | path join ($relpath | path dirname))
			let output = ($ref | path join $relpath) + '.tmpl'
			$"{{- template \"nu/($relpath)\" -}}\n\n" | save -f $output
			print $"\t($relpath)"
		}
	}
}
