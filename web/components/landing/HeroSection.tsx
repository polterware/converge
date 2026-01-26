"use client";

import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";
import { cn } from "@/lib/utils";
import { motion } from "motion/react";
import { useState, useEffect } from "react";
import { VantaTrunkBackground } from "./VantaTrunkBackground";

interface ReleaseInfo {
  url: string;
  version?: string;
  source?: string;
}

export function HeroSection() {
  const [chaos, setChaos] = useState(1.5);
  const [downloadUrl, setDownloadUrl] = useState<string | null>(
    process.env.NEXT_PUBLIC_DMG_DOWNLOAD_URL || null
  );

  useEffect(() => {
    // Se já tem URL configurada, não precisa buscar
    if (process.env.NEXT_PUBLIC_DMG_DOWNLOAD_URL) {
      return;
    }

    // Buscar versão mais recente da API
    fetch("/api/releases?type=latest")
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        throw new Error("Failed to fetch release");
      })
      .then((data: ReleaseInfo) => {
        setDownloadUrl(data.url);
      })
      .catch((error) => {
        console.error("Error fetching latest release:", error);
        // Manter estado atual (sem URL = botão desabilitado)
      });
  }, []);

  return (
    <section
      className={cn(
        "relative flex min-h-svh flex-col items-center justify-center gap-6 overflow-hidden px-4 py-16 text-center",
        "sm:gap-8 sm:py-24 md:py-32"
      )}
    >
      <VantaTrunkBackground chaos={chaos} />
      <div className="relative z-10 flex flex-col items-center justify-center gap-6 sm:gap-8">
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: "easeOut" }}
          className="font-serif text-4xl font-bold tracking-tight  sm:text-5xl md:text-6xl"
        >
          Converge
        </motion.h1>
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: "easeOut", delay: 0.2 }}
          className="max-w-2xl text-lg  sm:text-xl"
        >
          Pomodoro on Mac. Real focus.
        </motion.p>
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5, ease: "easeOut", delay: 0.4 }}
          className="flex flex-col gap-4 sm:flex-row sm:gap-3"
        >
          {downloadUrl ? (
            <motion.div
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              transition={{ duration: 0.2 }}
              onHoverStart={() => setChaos(0.2)}
              onHoverEnd={() => setChaos(1.5)}
            >
              <Button asChild size="lg" variant="outline">
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
            </motion.div>
          ) : (
            <motion.div
              onHoverStart={() => setChaos(0.2)}
              onHoverEnd={() => setChaos(1.5)}
            >
              <Button size="lg" disabled >
                <Download className="size-4" />
                Download coming soon
              </Button>
            </motion.div>
          )}
        </motion.div>
      </div>
    </section>
  );
}
