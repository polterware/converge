import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";
import { cn } from "@/lib/utils";

const downloadUrl = process.env.NEXT_PUBLIC_DMG_DOWNLOAD_URL;

export function DownloadSection() {
  return (
    <section
      className={cn(
        "mx-auto max-w-2xl px-4 py-16 text-center",
        "sm:py-24 md:py-32"
      )}
    >
      <h2 className="mb-4 text-3xl font-bold tracking-tight sm:text-4xl">
        Download Converge
      </h2>
      <p className="mb-8 text-muted-foreground">
        macOS only. Drag the app to Applications after opening the DMG.
      </p>
      {downloadUrl ? (
        <Button asChild size="lg">
          <a
            href={downloadUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2"
          >
            <Download className="size-4" />
            Download Converge (DMG)
          </a>
        </Button>
      ) : (
        <Button size="lg" disabled>
          <Download className="size-4" />
          Download coming soon
        </Button>
      )}
    </section>
  );
}
