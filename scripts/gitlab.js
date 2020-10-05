const axios = require('axios');
const { stringify } = require('querystring');

module.exports = {
  async deleteRegistryRepository(repositoryID, projectID, token, dryRun = false) {
    let tags = 'firstTime';
    while (!dryRun && tags.length > 0) {
      tags = (await axios.get(`https://gitlab.com/api/v4/projects/${projectID}/registry/repositories/${repositoryID}/tags?private_token=${process.env.GITLAB_ACCESS_TOKEN}`)).data
      tags.forEach(async (tag) => {
        console.log(`${dryRun ? 'not' : ''} deleting tag ${tag.name}`);
        if (!dryRun) {
          try {
            await axios.delete(`https://gitlab.com/api/v4/projects/${projectID}/registry/repositories/${repositoryID}/tags/${tag.name}?private_token=${process.env.GITLAB_ACCESS_TOKEN}`)
          } catch (e) {
            console.error(`e.response.status for tag.name`);
          }
        }
      })
    }

    await axios.delete(`https://gitlab.com/api/v4/projects/${projectID}/registry/repositories/${repositoryID}?private_token=${process.env.GITLAB_ACCESS_TOKEN}`)
  },

  async getRunner(id) {
    return (await axios.get(`https://gitlab.com/api/v4/runners/${id}?private_token=${process.env.GITLAB_ACCESS_TOKEN}`)).data
  },

  async getRunners(options) {
    const url = `https://gitlab.com/api/v4/runners?${stringify({private_token: process.env.GITLAB_ACCESS_TOKEN, ...options})}`
    console.log(url)
    return (await axios.get(url)).data || []
  },

  getIDs(runners) {
    return (runners).map(r => r.id)
  },

  async getRunnersByDescription(descriptionRegexes, options) {
    return (await this.getRunners(options)).filter(r => {
      return descriptionRegexes.some(dr => {
        return r.description.match(dr)
      })
    })
  },

  async deleteFromProjects(id) {
    const projects = (await axios.get(`https://gitlab.com/api/v4/runners/${id}?private_token=${process.env.GITLAB_ACCESS_TOKEN}`)).data.projects;
    await Promise.all(projects.map(async p => {
      console.log(`trying https://gitlab.com/api/v4/projects/${p.id}/runners/${id}?private_token=${process.env.GITLAB_ACCESS_TOKEN}`);
      console.log((await axios.delete(`https://gitlab.com/api/v4/projects/${p.id}/runners/${id}?private_token=${process.env.GITLAB_ACCESS_TOKEN}`)).data)
    }))
  },

  async deleteRunnersRecursive(descriptionRegex, options) {
    runners = await this.getRunnersByDescription(descriptionRegex)
    if (runners.length === 0) { return }
    await this.deleteRunners(this.getIDs(runners))
    return await this.deleteRunnersRecursive(descriptionRegex, options)
  },

  async deleteRunners(ids) {
    await Promise.all(ids.map(async id => {
      try {
        console.log((await axios.delete(`https://gitlab.com/api/v4/runners/${id}?private_token=${process.env.GITLAB_ACCESS_TOKEN}`)).data)
      } catch (error) {
        console.error(`${id}: ${JSON.stringify(error.response.data)}`);
      }
    }))
    return ids
  }
}
