import { NextRequest, NextResponse } from "next/server";

/**
 * API Route para gerenciar informações sobre releases
 * 
 * GET /api/releases/latest - Retorna URL da versão mais recente
 * GET /api/releases/appcast - Retorna appcast.xml (se usando Supabase)
 */

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_BUCKET = process.env.SUPABASE_BUCKET_NAME || "releases";
const GITHUB_REPO = process.env.GITHUB_REPO; // formato: usuario/repo

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const type = searchParams.get("type") || "latest";

  try {
    if (type === "latest") {
      return await getLatestRelease();
    } else if (type === "appcast") {
      return await getAppcast();
    } else {
      return NextResponse.json(
        { error: "Invalid type parameter. Use 'latest' or 'appcast'" },
        { status: 400 }
      );
    }
  } catch (error) {
    console.error("Error in releases API:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

/**
 * Retorna a URL da versão mais recente
 * Prioriza: 1. Variável de ambiente, 2. Supabase, 3. GitHub Releases
 */
async function getLatestRelease() {
  // Opção 1: URL direta configurada
  const directUrl = process.env.NEXT_PUBLIC_DMG_DOWNLOAD_URL;
  if (directUrl) {
    return NextResponse.json({
      url: directUrl,
      source: "environment",
    });
  }

  // Opção 2: Buscar do Supabase Storage
  if (SUPABASE_URL) {
    try {
      // Listar arquivos no bucket para encontrar o mais recente
      const response = await fetch(
        `${SUPABASE_URL}/storage/v1/object/list/${SUPABASE_BUCKET}?prefix=Pomodoro-&sortBy=created_at&order=desc&limit=1`,
        {
          headers: {
            apikey: process.env.SUPABASE_ANON_KEY || "",
          },
        }
      );

      if (response.ok) {
        const data = await response.json();
        if (data.length > 0) {
          const latestFile = data[0];
          const url = `${SUPABASE_URL}/storage/v1/object/public/${SUPABASE_BUCKET}/${latestFile.name}`;
          return NextResponse.json({
            url,
            version: extractVersion(latestFile.name),
            source: "supabase",
          });
        }
      }
    } catch (error) {
      console.error("Error fetching from Supabase:", error);
    }
  }

  // Opção 3: Buscar do GitHub Releases
  if (GITHUB_REPO) {
    try {
      const response = await fetch(
        `https://api.github.com/repos/${GITHUB_REPO}/releases/latest`,
        {
          headers: {
            Accept: "application/vnd.github.v3+json",
            ...(process.env.GITHUB_TOKEN && {
              Authorization: `token ${process.env.GITHUB_TOKEN}`,
            }),
          },
        }
      );

      if (response.ok) {
        const release = await response.json();
        const dmgAsset = release.assets.find((asset: { name: string }) =>
          asset.name.endsWith(".dmg")
        );

        if (dmgAsset) {
          return NextResponse.json({
            url: dmgAsset.browser_download_url,
            version: release.tag_name,
            source: "github",
          });
        }
      }
    } catch (error) {
      console.error("Error fetching from GitHub:", error);
    }
  }

  return NextResponse.json(
    { error: "No release URL found. Configure NEXT_PUBLIC_DMG_DOWNLOAD_URL, SUPABASE_URL, or GITHUB_REPO" },
    { status: 404 }
  );
}

/**
 * Retorna o appcast.xml (apenas se usando Supabase)
 */
async function getAppcast() {
  if (!SUPABASE_URL) {
    return NextResponse.json(
      { error: "Supabase not configured" },
      { status: 400 }
    );
  }

  try {
    const appcastUrl = `${SUPABASE_URL}/storage/v1/object/public/${SUPABASE_BUCKET}/appcast.xml`;
    const response = await fetch(appcastUrl);

    if (response.ok) {
      const appcast = await response.text();
      return new NextResponse(appcast, {
        headers: {
          "Content-Type": "application/xml",
        },
      });
    } else {
      return NextResponse.json(
        { error: "Appcast not found" },
        { status: 404 }
      );
    }
  } catch (error) {
    console.error("Error fetching appcast:", error);
    return NextResponse.json(
      { error: "Failed to fetch appcast" },
      { status: 500 }
    );
  }
}

/**
 * Extrai versão do nome do arquivo (ex: "Pomodoro-1.0.dmg" -> "1.0")
 */
function extractVersion(filename: string): string | null {
  const match = filename.match(/Pomodoro-([0-9]+\.[0-9]+)\.dmg/);
  return match ? match[1] : null;
}
