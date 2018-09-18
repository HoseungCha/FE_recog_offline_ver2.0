function out = reportCodeExecution()
% Demonstration information
[out.FilePath,out.FileName,out.Ext]  = fileparts(matlab.desktop.editor.getActiveFilename);
out.ExecuteTime = datetime('now');
out.Author = 'Hoseung Cha';
out.AuthorContact = 'hoseungcha@gmail.com';
out.CodeSummary =  help(out.FileName);
end