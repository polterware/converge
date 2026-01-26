"use client";

import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";
import { cn } from "@/lib/utils";
import { motion } from "motion/react";
import { useEffect, useState } from "react";

interface ReleaseInfo {
  url: string;
  version?: string;
  source?: string;
}

export function DownloadSection() {
  const [downloadUrl, setDownloadUrl] = useState<string | null>(
    process.env.NEXT_PUBLIC_DMG_DOWNLOAD_URL || null
  );
  const [version, setVersion] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // Se já tem URL configurada, não precisa buscar
    if (process.env.NEXT_PUBLIC_DMG_DOWNLOAD_URL) {
      return;
    }

    // Buscar versão mais recente da API
    let cancelled = false;

    const fetchRelease = async () => {
      setIsLoading(true);
      try {
        const res = await fetch("/api/releases?type=latest");
        if (res.ok) {
          const data: ReleaseInfo = await res.json();
          if (!cancelled) {
            setDownloadUrl(data.url);
            if (data.version) {
              setVersion(data.version);
            }
          }
        }
      } catch (error) {
        if (!cancelled) {
          console.error("Error fetching latest release:", error);
          // Manter estado atual (sem URL = botão desabilitado)
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    };

    fetchRelease();

    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <motion.section
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: "-100px" }}
      className={cn(
        "mx-auto flex max-w-2xl flex-col items-center justify-center px-4 py-16 text-center",
        "sm:py-24 md:py-32"
      )}
    >
      <motion.h2
        variants={{
          hidden: { opacity: 0, y: 20 },
          visible: { opacity: 1, y: 0 },
        }}
        transition={{ duration: 0.6, ease: "easeOut" }}
        className="mb-4 font-serif text-3xl font-bold tracking-tight sm:text-4xl"
      >
        Download Converge
      </motion.h2>
      <motion.p
        variants={{
          hidden: { opacity: 0, y: 20 },
          visible: { opacity: 1, y: 0 },
        }}
        transition={{ duration: 0.6, ease: "easeOut", delay: 0.2 }}
        className="mb-8 text-muted-foreground"
      >
        macOS only. Drag the app to Applications after opening the DMG.
        {version && (
          <span className="block mt-2 text-sm">
            Latest version: {version}
          </span>
        )}
      </motion.p>
      {downloadUrl ? (
        <motion.div
          variants={{
            hidden: { opacity: 0, scale: 0.95 },
            visible: { opacity: 1, scale: 1 },
          }}
          transition={{ duration: 0.5, ease: "easeOut", delay: 0.4 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
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
        </motion.div>
      ) : (
        <motion.div
          variants={{
            hidden: { opacity: 0, scale: 0.95 },
            visible: { opacity: 1, scale: 1 },
          }}
          transition={{ duration: 0.5, ease: "easeOut", delay: 0.4 }}
        >
          <Button size="lg" disabled={isLoading}>
            <Download className="size-4" />
            {isLoading ? "Checking for updates..." : "Download coming soon"}
          </Button>
        </motion.div>
      )}
      <motion.footer
        variants={{
          hidden: { opacity: 0, y: 20 },
          visible: { opacity: 1, y: 0 },
        }}
        transition={{ duration: 0.6, ease: "easeOut", delay: 0.6 }}
        className="mt-16 text-sm text-muted-foreground"
      >
        Made by{" "}
        <a
          href="https://www.polterware.com"
          target="_blank"
          rel="noopener noreferrer"
          className="underline hover:text-foreground transition-colors"
        >
          polterware
        </a>
      </motion.footer>
    </motion.section>
  );
}
