import { $ } from "https://deno.land/x/zx_deno/mod.mjs";
import { expect } from "https://deno.land/x/expect/mod.ts";
import { exists } from "https://deno.land/std/fs/mod.ts";

Deno.test("deno-wrapper", async (t) => {
  const twd = await Deno.makeTempDir();
  const cwd = Deno.cwd();
  Deno.chdir(twd);
  try {
    await t.step("deno run", async () => {
      await $`deno run -A ${import.meta.resolve("./cli.ts")} 1.30.0`;
    });

    await t.step("denow and denow.bat exist", async () => {
      await Deno.readTextFile("denow");
      await Deno.readTextFile("denow.bat");
    });

    await t.step("./denow eval", async () => {
      const v = "" + (await $`./denow eval 'console.log(Deno.version.deno)'`);
      expect(v).toBe("1.30.0");
    });

    await t.step(".deno exists", async () => {
      expect(await exists(".deno")).toBeTruthy();
    });
  } finally {
    Deno.chdir(cwd);
    await Deno.remove(twd, { recursive: true });
  }
});