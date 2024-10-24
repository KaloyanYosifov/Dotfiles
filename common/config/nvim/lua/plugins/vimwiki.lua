return {
	"vimwiki/vimwiki",
	cmd = "VimwikiIndex",
	config = function()
		vim.g.vimwiki_list = {
			{
				path = "~/vimwiki/",
				auto_tags = 1,
			},
		}
	end,
}
