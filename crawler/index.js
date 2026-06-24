import { PuppeteerCrawler, Dataset } from "crawlee";

const crawler = new PuppeteerCrawler({
  async requestHandler({ request, page, enqueueLinks }) {
    await Dataset.pushData({
      url: request.url,
      title: await page.title(),
    });
    await enqueueLinks();
  },
});

await crawler.run(["https://crawlee.dev"]);
