"use client";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Monitor, Smartphone } from "lucide-react";
import { cn } from "@/lib/utils";
import { motion } from "motion/react";

const WARD_2017_URL = "https://www.journals.uchicago.edu/doi/full/10.1086/691462";
const UT_AUSTIN_URL =
  "https://news.utexas.edu/2017/06/26/the-mere-presence-of-your-smartphone-reduces-brain-power/";
const SCI_REPORTS_2023_URL =
  "https://www.nature.com/articles/s41598-023-36256-4";

export function WhyDesktopSection() {
  return (
    <motion.section
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: "-100px" }}
      className={cn(
        "mx-auto min-h-[100svh] max-w-5xl px-4 py-16",
        "sm:py-24 md:py-32"
      )}
    >
      <motion.h2
        variants={{
          hidden: { opacity: 0, y: 20 },
          visible: { opacity: 1, y: 0 },
        }}
        transition={{ duration: 0.6, ease: "easeOut" }}
        className="mb-4 text-center font-serif text-3xl font-bold tracking-tight sm:text-4xl"
      >
        Why not a mobile app?
      </motion.h2>
      <motion.p
        variants={{
          hidden: { opacity: 0, y: 20 },
          visible: { opacity: 1, y: 0 },
        }}
        transition={{ duration: 0.6, ease: "easeOut", delay: 0.1 }}
        className="mx-auto mb-12 max-w-2xl text-center text-muted-foreground"
      >
        Converge was purposefully made for Mac. Keeping your phone away is
        part of the design.
      </motion.p>

      <div className="grid gap-8 lg:grid-cols-2 lg:items-start">
        <motion.div
          variants={{
            hidden: { opacity: 0, x: -30 },
            visible: { opacity: 1, x: 0 },
          }}
          transition={{ duration: 0.6, ease: "easeOut", delay: 0.2 }}
        >
          <Card>
            <CardHeader>
              <motion.div
                initial={{ scale: 0 }}
                whileInView={{ scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, ease: "easeOut", delay: 0.3 }}
                className="mb-2 flex h-10 w-10 items-center justify-center rounded-lg bg-destructive/10 text-destructive"
              >
                <Smartphone className="size-5" />
              </motion.div>
              <CardTitle>Phone nearby = less focus</CardTitle>
              <CardDescription>
                Studies show that the <strong>mere presence</strong> of a smartphone
                reduces available cognitive capacity, even with the device
                turned off. The brain spends resources to suppress thoughts
                about the device — and less is left for the task at hand.
              </CardDescription>
            </CardHeader>
          </Card>
        </motion.div>

        <motion.div
          variants={{
            hidden: { opacity: 0, x: 30 },
            visible: { opacity: 1, x: 0 },
          }}
          transition={{ duration: 0.6, ease: "easeOut", delay: 0.3 }}
        >
          <Card>
            <CardHeader>
              <motion.div
                initial={{ scale: 0 }}
                whileInView={{ scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, ease: "easeOut", delay: 0.4 }}
                className="mb-2 flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary"
              >
                <Monitor className="size-5" />
              </motion.div>
              <CardTitle>Desktop keeps the phone away</CardTitle>
              <CardDescription>
                With the timer on Mac, you don't need your phone on the desk. Those who leave
                the phone in <strong>another room</strong> tend to perform
                better than those who keep it in their pocket or on the desk — and much better than
                those who leave it in sight.
              </CardDescription>
            </CardHeader>
          </Card>
        </motion.div>
      </div>

      <motion.div
        variants={{
          hidden: { opacity: 0, y: 20 },
          visible: { opacity: 1, y: 0 },
        }}
        transition={{ duration: 0.6, ease: "easeOut", delay: 0.5 }}
        className="mt-10 rounded-xl border bg-muted/30 p-6"
      >
        <h3 className="mb-3 text-sm font-semibold uppercase tracking-wider text-muted-foreground">
          References
        </h3>
        <ul className="space-y-2 text-sm text-muted-foreground">
          <li>
            <a
              href={WARD_2017_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary underline underline-offset-2 hover:no-underline"
            >
              Ward et al. (2017)
            </a>{" "}
            — &quot;Brain Drain: The Mere Presence of One&apos;s Own Smartphone
            Reduces Available Cognitive Capacity&quot;,{" "}
            <em>Journal of Consumer Research</em>.
          </li>
          <li>
            <a
              href={UT_AUSTIN_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary underline underline-offset-2 hover:no-underline"
            >
              UT Austin (2017)
            </a>{" "}
            — &quot;The Mere Presence of Your Smartphone Reduces Brain
            Power&quot;.
          </li>
          <li>
            <a
              href={SCI_REPORTS_2023_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary underline underline-offset-2 hover:no-underline"
            >
              Scientific Reports (2023)
            </a>{" "}
            — &quot;The mere presence of a smartphone reduces basal attentional
            performance&quot; (replication with ~800 participants).
          </li>
        </ul>
      </motion.div>
    </motion.section>
  );
}
