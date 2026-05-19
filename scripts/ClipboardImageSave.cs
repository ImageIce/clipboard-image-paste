using System;
using System.Collections.Specialized;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Windows.Forms;

internal static class ClipboardImageSave
{
    [STAThread]
    private static int Main(string[] args)
    {
        try
        {
            string outputDir = Path.Combine(Environment.CurrentDirectory, ".clipboard-images");
            string format = "at-path";
            bool noClipboard = false;

            for (int i = 0; i < args.Length; i++)
            {
                string arg = args[i];
                if (IsOption(arg, "output-dir", "OutputDir") && i + 1 < args.Length)
                {
                    outputDir = args[++i];
                }
                else if (IsOption(arg, "format", "Format") && i + 1 < args.Length)
                {
                    format = args[++i];
                }
                else if (IsOption(arg, "no-clipboard", "NoClipboard"))
                {
                    noClipboard = true;
                }
                else if (!arg.StartsWith("-", StringComparison.Ordinal))
                {
                    format = arg;
                }
            }

            string imagePath = SaveClipboardImage(outputDir);
            string reference = FormatImageReference(imagePath, format);

            if (!noClipboard)
            {
                Clipboard.SetText(reference, TextDataFormat.UnicodeText);
            }

            Console.WriteLine(reference);
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine(ex.Message);
            return 1;
        }
    }

    private static bool IsOption(string value, string longName, string powershellName)
    {
        return string.Equals(value, "--" + longName, StringComparison.OrdinalIgnoreCase) ||
            string.Equals(value, "-" + powershellName, StringComparison.OrdinalIgnoreCase);
    }

    private static string SaveClipboardImage(string outputDir)
    {
        Directory.CreateDirectory(outputDir);
        string destination = Path.Combine(outputDir, "clipboard-image-" + DateTime.Now.ToString("yyyyMMdd-HHmmss-fff") + ".png");

        using (Image image = Clipboard.GetImage())
        {
            if (image != null)
            {
                image.Save(destination, ImageFormat.Png);
                return destination;
            }
        }

        if (Clipboard.ContainsFileDropList())
        {
            StringCollection files = Clipboard.GetFileDropList();
            foreach (string file in files)
            {
                if (File.Exists(file) && IsImageExtension(file))
                {
                    using (Image image = Image.FromFile(file))
                    {
                        image.Save(destination, ImageFormat.Png);
                    }
                    return destination;
                }
            }
        }

        throw new InvalidOperationException("The clipboard does not contain a bitmap image or image file.");
    }

    private static bool IsImageExtension(string path)
    {
        string extension = Path.GetExtension(path).ToLowerInvariant();
        switch (extension)
        {
            case ".png":
            case ".jpg":
            case ".jpeg":
            case ".gif":
            case ".bmp":
            case ".webp":
            case ".tif":
            case ".tiff":
                return true;
            default:
                return false;
        }
    }

    private static string FormatImageReference(string imagePath, string format)
    {
        string absolutePath = Path.GetFullPath(imagePath);
        string relativePath = GetRelativePath(Environment.CurrentDirectory, absolutePath);
        string claudePath = absolutePath.Replace('\\', '/');

        switch ((format ?? string.Empty).ToLowerInvariant())
        {
            case "path":
                return relativePath;
            case "absolute":
                return absolutePath;
            case "at-absolute":
                return "@" + absolutePath;
            case "claude-path":
                return claudePath;
            case "claude-prompt":
                return "Analyze this image: " + claudePath;
            case "markdown":
                return "![clipboard image](" + relativePath + ")";
            case "at-path":
            default:
                return "@" + relativePath;
        }
    }

    private static string GetRelativePath(string basePath, string targetPath)
    {
        string fullBase = Path.GetFullPath(basePath).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        string fullTarget = Path.GetFullPath(targetPath);

        Uri baseUri = new Uri(fullBase);
        Uri targetUri = new Uri(fullTarget);
        if (!string.Equals(baseUri.Scheme, targetUri.Scheme, StringComparison.OrdinalIgnoreCase))
        {
            return fullTarget;
        }

        string relative = Uri.UnescapeDataString(baseUri.MakeRelativeUri(targetUri).ToString());
        return relative.Replace('/', Path.DirectorySeparatorChar);
    }
}
