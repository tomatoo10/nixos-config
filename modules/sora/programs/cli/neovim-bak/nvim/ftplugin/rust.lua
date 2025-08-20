if vim.g.did_load_rust_plugin then  
  return  
end  
vim.g.did_load_rust_plugin = true  
  
vim.lsp.start({  
  name = 'rust-analyzer',  
  cmd = { 'rust-analyzer' },  
  root_dir = vim.fs.dirname(vim.fs.find({ 'Cargo.toml' }, { upward = true })[1]),  
})
