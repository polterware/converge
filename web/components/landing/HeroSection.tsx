import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";
import { cn } from "@/lib/utils";

const downloadUrl = process.env.NEXT_PUBLIC_DMG_DOWNLOAD_URL;

export function HeroSection() {
  return (
    <section
      className={cn(
        "flex flex-col items-center justify-center gap-6 px-4 py-16 text-center",
        "sm:gap-8 sm:py-24 md:py-32"
      )}
    >
      <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl">
        Converge
      </h1>
      <p className="max-w-2xl text-lg text-muted-foreground sm:text-xl">
        Pomodoro on Mac. Real focus.
      </p>
      <div className="flex flex-col gap-4 sm:flex-row sm:gap-3">
        {downloadUrl ? (
          <Button asChild size="lg">
            <a
              href={downloadUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2"
            >
              <Download className="size-4" />
              Download for Mac
            </a>
          </Button>
        ) : (
          <Button size="lg" disabled>
            <Download className="size-4" />
            Download coming soon
          </Button>
        )}
      </div>
    </section>
  );
}
