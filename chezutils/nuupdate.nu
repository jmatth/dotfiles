const nurefs = [
	'private_Library/private_Application Support/nushell'
	'dot_config/nushell'
	'AppData/Roaming/nushell'
]

const srcpath = path self

def main [] {
	let chezroot = $srcpath | path split | drop 3 | path join
	let cheztmpldir = $srcpath | path split | drop 2 | path join .chezmoitemplates nu
	print $cheztmpldir
	# Do this annoying lambda because the glob command doesn't work on Windows.
	let sources = do { cd $cheztmpldir; ls -f **/* | where type != dir | get name }
	for ref in $nurefs {
		print $ref
		for $source in $sources {
			print $source
			print $cheztmpldir
			let relpath = $source | path relative-to $cheztmpldir
			mkdir ($ref | path join ($relpath | path dirname))
			let output = ($ref | path join $relpath) + '.tmpl'
			$"{{- template \"nu/($relpath | str replace -a '\' '/')\" -}}\n\n" | save -f $output
			print $"\t($relpath)"
		}
	}
}
